

/**
* LIFe model
*/
#include <math.h>
#include <stdlib.h>
#include "LIFe.h"

// macros -- soma and dendrites
#define V (y[0])
#define dV (dydt[0])


/*******************
 * Model Functions *
 *******************/


LIFe::LIFe(double dd) {
    
    //dt is now a global variable that has the value of dd, which came from the 
    dt=dd;

    y.push_back(-70.0);
    dydt.push_back(0.0);

    Vthresh = -54.0;      // firing threshold
    Vrest= -70.0;         // resting membrane potential
    Vreset = -80.0;       // reset voltage to go to after a spike
    Vspike = 20.0;
    V = Vrest;         // starting value for Vm

    Cm = 0.100; //nf 
    Rm =60.0; //MOhms
    Gl = 1.0/Rm;

    NOISE=1;

    // ornstein uhlenbeck stuff
    gavgi = 0.0000005;
    setTaui(1.8);
    setDi(0.000005);
    si = 0;
    Ei = -65;
    
    gavge = 0.000002;
    setTaue(1.8);
    setDe(0.00002);
    se = 0;
    Ee = 0;
    
    //This is to initialize the vector and tell it how many values it should be filled with.
    
    //Detection of Spike State and PSG
    detect = new SpikeDetect(-20, 2);
    
}

LIFe::~LIFe(void) {}

void LIFe::derivs(void) {

	if (V > Vthresh) {
		if (V > Vspike-1) {
			V = Vreset;
		} else {
			V = Vspike;
		}
	} else {

		if (NOISE) {
			se = (gavge + (se - gavge) * exp(-dt / taue) + Ae * (((double)rand()/RAND_MAX)-0.5));
			si = (gavgi + (si - gavgi) * exp(-dt / taui) + Ai * (((double)rand()/RAND_MAX)-0.5));
			if (se < 0) se=0;
			if (si < 0) si=0;
			dV = (-1.0/Cm)*(Gl*(V-Vrest) - Iapp/1000.0 + (se * (V - Ee)) + (si * (V - Ei)));
		}
		 else {
			dV = (-1.0/Cm)*(Gl*(V-Vrest) - Iapp/1000.0);
		} 
	}
}






