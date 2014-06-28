/**
 * HybridNetwork.h = Header file for the HybridNetwork
 */

#ifndef HYBRIDNETWORK_H
#define HYBRIDNETWORK_H

#include <default_gui_model.h>
#include <QtGui>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

#include "../StandAloneSim/Network.h"
#include "../StandAloneSim/RunParams.h"


using namespace std;
extern double params_dt;
extern double params_tend;
extern int params_downsample;
extern int params_saving;
extern string params_comment;

class HybridNetwork : public DefaultGUIModel {
public:

    HybridNetwork(void);
    virtual ~HybridNetwork(void);

    void execute(void);
    void ZeroOutputs();
    void NetDialog();
    void initSim();

protected:

    void update(DefaultGUIModel::update_flags_t);

private:

    double rate;
    int upsample;
    int filenum, series, tempseries;
    double period;
    double len;
    double tcnt;

    int *buf;
    int ncells;
    int bufsize;
    int acquire;
    int acquire_flag;

    int realind;

    QString filename;
    QFileDialog FileOpenDialog;

    Network *n;
};

#endif
