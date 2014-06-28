#include <math.h> 
#include "PatchedCell.h"

    
#define V (y[0])
#define dV (dydt[0])

    
// synaptic kinetics
const double PatchedCell::psgrise = 0.7;
const double PatchedCell::psgfall = 9.3;

PatchedCell::PatchedCell(double dd) {
    
    //dt is now a global variable that has the value of dd, which came from the HybridNetwork period (1000.0/rate)
    dt=dd;
    
    //This is to initialize the vector and tell it how many values it should be filled with.
    y.push_back(-65.0);
    dydt.push_back(0);

    //Detection of Spike State and PSG
    detect = new SpikeDetect(-20, 2);
    
    // Initialize/Allocate Memory to pointer psg
    psg1 = new PSG(psgrise, psgfall, dt);
}

PatchedCell::~PatchedCell() {}

//derivs function unique to PatchedCell
void PatchedCell::derivs(void) {
    dV = 0;
}
