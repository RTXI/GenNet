#include <math.h>
#include <default_gui_model.h>
#include "RTSim.h"

#include <string>
#include <iostream>
#include <fstream>

using namespace std; 

extern "C" Plugin::Object *createRTXIPlugin(void) {
    return new RTSim();
}

static DefaultGUIModel::variable_t vars[] = {
    {
        "Iin",
        "",
        DefaultGUIModel::INPUT,
    },
    {
        "Vm",
        "",
        DefaultGUIModel::OUTPUT,
    },
    {
        "Cell type",
        "Type of cell to simulate",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::UINTEGER,
    },
    {
        "Rate",
        "How fast to integrate in silico network (Hz)",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
    },
    {
        "Offset (pA)",
        "Offset current applied to cell",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
    },
    {
        "Gl (nS)",
        "Membrane leak conductance (nS)",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
    },
    {
        "Di",
        "Inhibitory noise component of OU process",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
    },
    {
        "De",
        "Excitatory noise component of OU process",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
    },
    {
        "gavgi",
        "Excitatory noise component of OU process",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
    },
    {
        "gavge",
        "Excitatory noise component of OU process",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
    },
    {
        "taui",
        "Excitatory noise component of OU process",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
    },
    {
        "taue",
        "Excitatory noise component of OU process",
        DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
    },
};


static size_t num_vars = sizeof(vars)/sizeof(DefaultGUIModel::variable_t);

//Constructor
RTSim::RTSim(void) : DefaultGUIModel("RTSim",::vars,::num_vars) {

    rate = 50000;
    type = 12;
    offset = 0;
    n = 0;

    Gl = 0.1;
    Di = 0.000001;
    De = 0.000001;
    
    gavge = 0.01;
    gavgi = 0.01;
    taui = 8;
    taue = 2;
    
    period = RT::System::getInstance()->getPeriod()*1e-6;  // ms

    upsample = static_cast<int>(ceil(period * rate / 1000.0));

	 createGUI(vars, num_vars);
    
    update(INIT);
    refresh();
	 QTimer::singleShot(0, this, SLOT(resizeMe()));
}

//Destructor
RTSim::~RTSim(void) {
}

void RTSim::execute(void) {
    
    output(0) = 0;
    if (n) {
            for (int i = 0; i < upsample; i++) {
                n->execute(offset+input(0)*1e12);
            } 
	output(0) = n->getCellVm();
    }
}

void RTSim::update(DefaultGUIModel::update_flags_t flag) {

    switch(flag) {

        case INIT:
            setParameter("Rate", rate);
            setParameter("Cell type", type);
            setParameter("Offset (pA)", offset);
            setParameter("Gl (nS)", Gl);
            setParameter("Di", Di);
            setParameter("De", De);
            setParameter("gavgi", gavgi);
            setParameter("gavge", gavge);
            setParameter("taui", taui);
            setParameter("taue", taue);
            
            output(0) = 0.0;

            break;

        case MODIFY:

            rate = getParameter("Rate").toDouble();   
            type = getParameter("Cell type").toInt();   
            offset = getParameter("Offset (pA)").toDouble();  
            Gl = getParameter("Gl (nS)").toDouble();  
            Di = getParameter("Di").toDouble();  
            De = getParameter("De").toDouble();  
            gavgi = getParameter("gavgi").toDouble();  
            gavge = getParameter("gavge").toDouble();  
            taui = getParameter("taui").toDouble();  
            taue = getParameter("taue").toDouble();  

            initSim();

            period = RT::System::getInstance()->getPeriod()*1e-6;  // ms
            upsample = static_cast<int>(ceil(period*rate/1000.0));

            break;
        case PERIOD:
            period = RT::System::getInstance()->getPeriod()*1e-6;
            upsample = static_cast<int>(ceil(period*rate/1000.0));

        case PAUSE:
            output(0) = 0.0;
            break;

        default:
            break;
    }
}

void RTSim::initSim() {

    if (n) {
        delete(n);
        n = 0;
    }

    n = new InitCell(rate);
    n->setType(type);
    n->BuildNet();
    
    n->setGl(Gl);
    n->setDi(Di);
    n->setDe(De);
    n->setGavgi(gavgi);
    n->setGavge(gavge);
    n->setTaui(taui);
    n->setTaue(taue);
}
