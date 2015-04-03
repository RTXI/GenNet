

/**
* IZClass1 model
*/
#include <math.h>
#include <stdlib.h>
#include "IZClass1.h"

// macros -- soma and dendrites
#define V (y[0])
#define u (y[1])

#define dV (dydt[0])
#define du (dydt[1])


/*******************
 * Model Functions *
 *******************/


IZClass1::IZClass1(double dd) {
    
    //dt is now a global variable that has the value of dd, which came from the 
    dt=dd;

      
    //Class 1 excitable
    a=0.02;
    b=-0.1;
    c=-55;
    d=6;
    
    NOISE=1;

    //a=1;       b=0.2;     c=-60;     d=-10;
    //a = 0.01;     b = 0.2;     c = -65;    d = 8;
    // ornstein uhlenbeck stuff
    gavgi = 0.00;
    taui = 0.8;
    Di = 0.01;
    si = 0;
    Ei = -75;
    
    gavge = 0.00;
    taue = 0.8;
    De = 0.01;
    se = 0;
    Ee = 0;
    
    //This is to initialize the vector and tell it how many values it should be filled with.
    y.push_back(-65.0);
    y.push_back(b*-65.0);
      
    dydt.push_back(0);
    dydt.push_back(0);
    
    //Detection of Spike State and PSG
    detect = new SpikeDetect(-20, 2);
    
    
    Ae = sqrt((De * taue / 2) * (1 - exp(-2 * dt / taue)));
    Ai = sqrt((Di * taui / 2) * (1 - exp(-2 * dt / taui)));
}

IZClass1::~IZClass1(void) {}

void IZClass1::derivs(void) {
 //   cout << "V: " << V << endl;
    if (V > 30) {
        V = c;
        u = u + d;
        dV = 0;
        du = 0;

    } else {
        
        if (NOISE) {
            se = (gavge + (se - gavge) * exp(-dt / taue) + Ae * (((double)rand()/RAND_MAX)-0.5));
            si = (gavgi + (si - gavgi) * exp(-dt / taui) + Ai * (((double)rand()/RAND_MAX)-0.5));
            if (se < 0) se=0;
            if (si < 0) si=0;
            dV = 0.04*V*V + 4.1*V + 108 - u + Iapp - (se * (V - Ee)) - (si * (V - Ei));
        }
        else {
            dV = 0.04*V*V + 4.1*V + 108 - u + Iapp;
        } 
        du = a*(b*V-u); 
    }
}
