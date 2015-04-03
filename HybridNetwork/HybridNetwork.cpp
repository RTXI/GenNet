/**
 * Hybrid Network of arbitrary topology. Tilman Kispersky, Mike Economo, Pratik Randeria
 */

#include <math.h>
#include <default_gui_model.h>
#include "HybridNetwork.h"
#include <QtGui>

#include <string>
#include <iostream>
#include <fstream>

using namespace std;

extern "C" Plugin::Object *createRTXIPlugin(void) {
    return new HybridNetwork();
}

static DefaultGUIModel::variable_t vars[] = {
    {
        "Patched Vm",
        "",
        DefaultGUIModel::INPUT,
    },
    {
        "Network File",
        "File that contains hybrid network topology",
        DefaultGUIModel::COMMENT,
    },
    
    {
        "Rate",
        "How fast to integrate in silico network (Hz)",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
    },
    {
        "Length",
        "How long to record (s)",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
    },
    {
        "Acquire?",
        "1 for acquire, 0 for no thanks",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::UINTEGER,
    },
    {
        "Series #",
        "Controls the letter in the filename",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::UINTEGER,
    },
    {
        "Comment",
        "Information regarding this dataset",
        DefaultGUIModel::COMMENT,
    },
    {
        "Current to real cell",
        "",
        DefaultGUIModel::OUTPUT,
    },
    {
        "Vm of cell 0",
        "",
        DefaultGUIModel::OUTPUT,
    },
};


static size_t num_vars = sizeof(vars)/sizeof(DefaultGUIModel::variable_t);

//Constructor
HybridNetwork::HybridNetwork(void) : DefaultGUIModel("Hybrid Network",::vars,::num_vars) {

    realind = -666;
    rate = 50000;
    period = RT::System::getInstance()->getPeriod()*1e-6;  // ms
    len = 1.0;
    acquire_flag = 0;

    upsample = static_cast<int>(ceil(period*rate/1000.0));
    acquire = 0;
    filenum = 1;
    series = 1;
    tcnt = 0;
    ::params_comment = "";

    n = 0;

	 createGUI(vars, num_vars);

    update(INIT);
    refresh();
	 QTimer::singleShot(0, this, SLOT(resizeMe()));
}

//Destructor
HybridNetwork::~HybridNetwork(void) {}


void HybridNetwork::execute(void) {

    output(0) = 0;
    output(1) = 0;

    if (n) {
        if (realind != -666) {
            n->setCellVm(realind, input(0));
        }
        tcnt += period / 1000;
        if (tcnt < (len + 1e-9)) {
            for (int i = 0; i < upsample; i++) {
                n->execute();
            }
	    output(0) = n->getRealCellCurrent();
            output(1) = n->getCellVm(0);
        } else {
            setActive(false);
            if (acquire) {
                acquire_flag = 1;
                acquire = 0;
            }
        }
    }
}


void HybridNetwork::NetDialog() {

    filename = getComment("Network File");
    if(filename.isEmpty() or filename=="Unable to open file." or filename=="Press MODIFY") {
        filename = FileOpenDialog.getOpenFileName(this, tr("Select Network Config File"), "/usr/src/rtxi/models/NDLModels/HybridNetwork/nets/", tr("*.net"), 0, 0);

    }
}


void HybridNetwork::update(DefaultGUIModel::update_flags_t flag) {

    switch(flag) {

    case INIT:
        setParameter("Rate", rate);
        setParameter("Length", len);
        setParameter("Acquire?", acquire);
        setParameter("Series #", series);
        setComment("Network File", "Press MODIFY");

        setComment("Comment", QString::fromStdString(params_comment));
        
        output(0) = 0.0;
        output(1) = 0.0;
        break;

    case MODIFY:

        NetDialog();

        setComment("Network File", filename.remove("/usr/src/rtxi/models/NDLModels/HybridNetwork/nets/"));

        rate = getParameter("Rate").toDouble();   // Hz
        len = getParameter("Length").toDouble();   // s
        ::params_comment = getParameter("Comment").toStdString();
        acquire = getParameter("Acquire?").toUInt();
        tempseries = getParameter("Series #").toUInt();

        if (tempseries != series) { 
             series = tempseries;
             filenum = 1;
        }

        initSim();

        tcnt = 0;
        period = RT::System::getInstance()->getPeriod()*1e-6;  // ms
        upsample = static_cast<int>(ceil(period*rate/1000.0));
        break;

    case PERIOD:
        period = RT::System::getInstance()->getPeriod()*1e-6;
        upsample  = static_cast<int>(ceil(period*rate/1000.0));
		  break;

    case PAUSE:
        output(0) = 0.0;
        output(1) = 0.0;
        if (acquire_flag) {
            setParameter("Acquire?", acquire);
            n->setRecNum(filenum);
            n->WriteDatFile();
            filenum++;
            acquire_flag = 0;
        }
        break;

    default:
        break;
    }
}


void HybridNetwork::initSim() {

    if (n) {
        delete(n);
        n = 0;
    }

    ::params_tend = len*1000;
    ::params_downsample = upsample;
    ::params_saving = acquire;
    ::params_dt = period/upsample;
    n = new Network();
    n->setCellNum(series);
    n->LoadNet(filename.toStdString());
    realind = n->getRealIndex();
}
