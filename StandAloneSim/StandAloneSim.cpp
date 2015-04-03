/**
 * StandAloneSim is the wrapper class around 'Network' which permits running our simulator
 * as a stand-alone, purely virtual setup.
 * It reads command line arguments and calls the right functions in 'Network'
 */
 
#include <math.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include "StandAloneSim.h"
#include "RunParams.h"

using namespace std; 

extern double params_dt;
extern double params_tend;


//Constructor
StandAloneSim::StandAloneSim(void) {
     n = new Network();
}
    
//Destructor
StandAloneSim::~StandAloneSim(void) {
}

void StandAloneSim::execute(void) {
    n->execute();
}

void StandAloneSim::LoadNet(string fn) {
    n->LoadNet(fn);
}

void StandAloneSim::runNegativeTime(double dt) {
    n->runNegativeTime(dt);
}

void StandAloneSim::setPrint(int p) {
    n->setPrint(p);
}

// This functionality is deprecated in favor of the more advanced parameter
// changing syntax
void StandAloneSim::updateIh(double d) {
    //((OCell *)(SuperCellVector[2]))->setGh(d);
    //((OCell *)(SuperCellVector[3]))->setGh(d);
}

void StandAloneSim::WriteDatFile() {
    n->WriteDatFile();
}

void StandAloneSim::setRecNum(int rn) {
    n->setRecNum(rn);
}

/**
 * Entry point for the simulator
 */
int main(int argc, char *argv[]) {
    
    int recnum = 1;
    char *recstr;
    string netfn;    
    int c;

    // setting the record number (-r n)
    while ((c = getopt(argc, argv, "r:")) != -1) {
        switch(c) {
            case 'r':
                recstr = optarg;
                recnum = atoi(recstr);
                break;
            case '?':
                if (optopt == 'c')
                    fprintf(stderr, "Option -%c requires an argument.\n", optopt);
                else if (isprint (optopt))
                    fprintf (stderr, "Unknown option `-%c'.\n", optopt); else
                    fprintf (stderr, "Unknown option character `\\x%x'.\n", optopt);
                    
                cout << "Usage: gn[-r n] net_filename" << endl;
                return 1;
            default:
                abort();
        }
    }
    // and the filename
    netfn = argv[argc - 1];

    // begin simulation
    double dt = params_dt;
    double tend = params_tend;
    
    // create a new network
    StandAloneSim *GN = new StandAloneSim();

    // read in netfile
    GN->LoadNet(netfn);
    
    // evolve the simulation to a steady state before the run begins    
    GN->runNegativeTime(dt);
    
    // set the record number for acquisition
    GN->setRecNum(recnum);

    for (double t = 0; t < tend-dt/2; t += dt) {
        
        // execute the simulator
        GN->execute();

        if (params_print && ((int)t % (int)(dt*10000)) == 0) {
            cout << "\r % Done: " << (int)(t/tend*100);
        }
    }
    if (params_print) cout << endl;
    GN->WriteDatFile();
    delete(GN);
}
