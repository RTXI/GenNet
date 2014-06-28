

/**
* LIFi model
*/
#include <math.h>
#include <stdlib.h>
#include "LIFi.h"

// macros -- soma and dendrites
#define V (y[0])
#define dV (dydt[0])


/*******************
 * Model Functions *
 *******************/


LIFi::LIFi(double dd) {
    
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
    Rm =40.0; //MOhms
    Gl = 1.0/Rm;
    NOISE=1;

    // ornstein uhlenbeck stuff
    gavgi = 0.000001;
    si = 0;
    Ei = -65;
    Di = 0.000003;
    taui = 1.8;
    
    gavge = 0.000001;
    se = 0;
    Ee = 0;
    De = 0.000003;
    taue = 1.8;

    //This is to initialize the vector and tell it how many values it should be filled with.
    
    //Detection of Spike State and PSG
    detect = new SpikeDetect(-20, 2);
}

LIFi::~LIFi(void) {}

void LIFi::derivs(void) {

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






