/**
*  ECell model based on model Horacio used in Gloveli 2005
*  Has optional noise parameter
*/


#include <stdlib.h>
#include <math.h> 
#include "ECell.h"

const double ECell::GNa = 100.0;
const double ECell::GK  =  80.0;
//const double ECell::GL  =   0.1;
const double ECell::ENa =  50.0;
const double ECell::EK = -100.0;
const double ECell::EL  = -67.0;
const double ECell::Cm  =   1.0;
const double ECell::V0  = -65.0;

// macros -- soma
#define V (y[0])
#define m (y[1])
#define h (y[2])
#define n (y[3])

// macros derivatives
#define dV (dydt[0])
#define dm (dydt[1])
#define dh (dydt[2])
#define dn (dydt[3])
    

ECell::ECell(double dd) {
    
    //dt is now a global variable that has the value of dd, which came from the HybridNetwork period (1000.0/rate)
    dt=dd;
    
    //This is to initialize the vector and tell it how many values it should be filled with.
    y.push_back(V0);
    y.push_back(minf(V0));
    y.push_back(hinf(V0));
    y.push_back(ninf(V0));
    
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    Gl = 0.1;
    //Detection of Spike State and PSG
    detect = new SpikeDetect(-20, 2);
    
    // ornstein uhlenbeck stuff
    gavgi = 0.02;
    taui = 0.8;
    Di = 0.01;
    si = 0;
    Ei = -75;
    
    gavge = 0.02;
    taue = 0.8;
    De = 0.01;
    se = 0;
    Ee = 0;
    
    Ae = sqrt((De * taue / 2) * (1 - exp(-2 * dt / taue)));
    Ai = sqrt((Di * taui / 2) * (1 - exp(-2 * dt / taui)));
    
    NOISE = 0;
    
    type = SuperCell::ECELL;
}

//Destructor
ECell::~ECell(void) {}

/**
* Model Functions
*/

double ECell::am (double v) {
    if (fabs(v + 54) < 0.0001) {
        return 1.28;
    } else {
        return (0.32 * (54 + v)) / (1 - exp(-(v + 54) / 4.0));
    }
}

double ECell::bm (double v) {
    if (fabs(v + 27) < 0.0001) {
        return 1.4;
    } else {
        return (0.28 * (v + 27)) / (exp((v + 27) / 5.0) - 1);
    }
}

double ECell::ah (double v) {
    return 0.128 * exp(-(50 + v) / 18.0); 
}

double ECell::bh (double v) {
    return 4.0 / (1 + exp(-(v + 27) / 5.0)); 
}

double ECell::an (double v) {
    if (fabs(v + 52) < 0.0001) {
        return 0.16;
    } else {
        return 0.032 * (v + 52) / (1 - exp(-(v + 52) / 5.0));
    }
}

double ECell::bn (double v) {
    return 0.5 * exp(-(57 + v) / 40.0);
}

double ECell::taum (double v) {
    return 1.0 / (am(v) + bm(v));
}

double ECell::taun (double v) {
    return 1.0 / (an(v) + bn(v));
}

double ECell::tauh (double v) {
    return 1.0 / (ah(v) + bh(v));
}

double ECell::minf (double v) {
    return am(v) / (am(v) + bm(v));
}

double ECell::ninf (double v) {
    return an(v) / (an(v) + bn(v));
}

double ECell::hinf (double v) {
    return ah(v) / (ah(v) + bh(v));
}

void ECell::derivs(void) {
   
    double INa, IK, IL = 0;
    
    dm = (minf(V) - m) / taum(V);
    dh = (hinf(V) - h) / tauh(V);
    dn = (ninf(V) - n) / taun(V);
    
    INa = GNa * m * m * m * h * (V - ENa);
    IK = GK * n * n * n * n * (V - EK);
    IL = Gl * (V - EL);
    
    if (NOISE) {
        
        se = (gavge + (se - gavge) * exp(-dt / taue) + Ae * (((double)rand()/RAND_MAX)-0.5));
        si = (gavgi + (si - gavgi) * exp(-dt / taui) + Ai * (((double)rand()/RAND_MAX)-0.5));
        
        if (se < 0) se=0;
        if (si < 0) si=0;
        
        double Ii = si * (V - Ei);
        double Ie = se * (V - Ee);
        
        
        dV = (Iapp - INa - IK - IL - Ii - Ie) / Cm;
    }
    else {
        dV = (Iapp - INa - IK - IL) / Cm;
    }
}
