/**
* aeLIF model
*/
#include <math.h>
#include <stdlib.h>
#include "aeLIF.h"

// macros -- soma and dendrites
//#define V (y[0])
//#define w (y[1])
//#define ww (y[2])

//#define dV (dydt[0])
//#define dw (dydt[1])
//#define dww (dydt[2])

/*******************
 * Model Functions *
 *******************/


aeLIF::aeLIF(double dd) {
    
    //dt is now a global variable that has the value of dd, which came from the 
    dt=dd;

    y.push_back(-60.0);
    y.push_back(0.0);
    y.push_back(0.0);

    dydt.push_back(0.0);
    dydt.push_back(0.0);
    dydt.push_back(0.0);

    El = -65;
    Vt = -52.0;      // firing threshold
//    Vr = -53.0;      //Reset 
    Vspk = 20.0;
    deltT = 0.8;
    tauw = 25;
    a =-0.00005;
    b = 0.02;

    tauww = 500;
    aa = -0.000;
    bb = 0.001;


    y[0] = El;         // starting value for Vm

    Cm = 0.150; //nf 
    Gl = 0.0043;

    NOISE=1;

    // ornstein uhlenbeck stuff
    gavgi = 0.0000005*0;
    taui=1.8;
    Di=0.000005;
    si = 0;
    Ei = -70;
    
    gavge = 0.000002*0;
    taue=1.8;
    De=0.00002;
    se = 0;
    Ee = 0;
    
    //Detection of Spike State and PSG
    detect = new SpikeDetect(-20, 2);
    
}

aeLIF::~aeLIF(void) {}

void aeLIF::derivs(void) {
	if (y[0]>Vspk) {
		y[0] = -53;
		y[1] = y[1] + b;
		dydt[0] = 0;
		dydt[1] = 0;
                y[2] = y[2] + bb;
                dydt[2] = 0;
	} else {

		if (NOISE) {
			se = (gavge + (se - gavge) * exp(-dt / taue) + Ae * (((double)rand()/RAND_MAX)-0.5));
			si = (gavgi + (si - gavgi) * exp(-dt / taui) + Ai * (((double)rand()/RAND_MAX)-0.5));
			if (se < 0) se=0;
			if (si < 0) si=0;
			dydt[0] = (-1.0/Cm)*(Gl*(y[0]-El) - Gl*deltT*exp((y[0]-Vt)/deltT) + y[1]*(y[0] - El) + y[2]*(y[0]-El)- Iapp/1000.0 + (se * (y[0] - Ee)) + (si * (y[0] - Ei)));
			dydt[1] = (a*(y[0]-El) - y[1])/tauw;
			dydt[2] = (aa*(y[0]-El) -y[2])/tauww;
		}
		else {
			dydt[0] = (-1.0/Cm)*(Gl*(y[0]-El) - Gl*deltT*exp((y[0]-Vt)/deltT) + y[1]*(y[0]-El) +y[2]*(y[0]-El) - Iapp/1000.0);
			dydt[1] = (a*(y[0]-El) - y[1])/tauw;
			dydt[2] = (aa*(y[0]-El) - y[2])/tauww;
		} 
	}

//	if (dV>3e3) dV = 3e3;


}






