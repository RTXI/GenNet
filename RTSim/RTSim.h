/**
 * RTSim.h = Header file for the RTSim
 */

#ifndef RTSIM_H
#define RTSIM_H

#include <default_gui_model.h>
#include <QtGui>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

#include "../StandAloneSim/InitCell.h"


using namespace std;

class RTSim : public DefaultGUIModel
{
    public:

        RTSim(void);
        virtual ~RTSim(void);

        void execute(void);
        void initSim();

    protected:

        void update(DefaultGUIModel::update_flags_t);

    private:

        double rate;
        int upsample;
        double offset;
        double period;
        double Gl, Di, De, gavgi, gavge, taui, taue;

        int type;

        InitCell *n;
};

#endif
