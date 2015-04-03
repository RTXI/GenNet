/**
* Ghost cell. Its only got leak and is used to approximate a field potential
*/


#include <math.h> 
#include "GhostCell.h"

    
// macros
#define V (y[0])
#define dV (dydt[0])

//const double GhostCell::GL = 0.5;
const double GhostCell::EL = -70;
const double GhostCell::Cm = 0.1;
    
// synaptic kinetics
const double GhostCell::psgrise = 0.7;
const double GhostCell::psgfall = 9.3;

GhostCell::GhostCell(double dd) {
    
    //dt is now a global variable that has the value of dd, which came from the HybridNetwork period (1000.0/rate)
    dt=dd;
    
    //This is to initialize the vector and tell it how many values it should be filled with.
    y.push_back(-65.0);
    dydt.push_back(0);
    Gl = 0.01;
    //Detection of Spike State and PSG
    detect = new SpikeDetect(-20, 2);
    
    // Initialize/Allocate Memory to pointer psg
    psg1 = new PSG(psgrise, psgfall, dt);
}

GhostCell::~GhostCell() {}

//derivs function unique to GhostCell
void GhostCell::derivs(void) {
   
 //   double IL = Gl * (V - EL);
//    dV = (Iapp/1000  - IL) / Cm;
    V = Iapp/1000;
    dV = 0;
}
