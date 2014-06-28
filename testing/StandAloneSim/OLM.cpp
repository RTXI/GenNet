
/**
* O-LM cell from Tort et al. (adapted from Saraga and Skinner)
*/


// #include <math.h> 
#include <cmath>
#include "OLM.h"

const double OLM::VNa =  90.0;
const double OLM::GNa =  30.0;
const double OLM::VK  = -100.0;
const double OLM::GK  =  23.0;
const double OLM::VL  = -70.0;
//const double OLM::GL  =  0.05;
const double OLM::Va  = -90.0;
const double OLM::Ga  =  16.0;
const double OLM::Vh  = -32.9;
const double OLM::Cm  =  1.3;
const double OLM::V0 =  -65;


// macros -- soma and dendrites
#define V (y[0])
#define m (y[1])
#define h (y[2])
#define n (y[3])
#define a (y[4])    
#define b (y[5])
#define r (y[6])

// derivs
#define dV (dydt[0])
#define dm (dydt[1])
#define dh (dydt[2])
#define dn (dydt[3])
#define da (dydt[4])
#define db (dydt[5])
#define dr (dydt[6])


/*******************
 * Model Functions *
 *******************/
 
static inline double an(double v) {
    // linear approximation around undefined point
    if (abs(v - 25) < 0.01) {
        return 0.009 * v + 0.225;
    } else {
        return 0.018 * (v - 25) / (1 - exp(-(v - 25) / 25));
    }
}

static inline double bn(double v) {
    if (abs(v - 35) < 0.01) {
        return -0.0018 * v + 0.1062;
    } else {
        return 0.0036 * (v - 35) / (exp((v - 35) / 12) - 1);
    }
}

static inline double am(double v) {
    if (abs(v + 38) < 0.01) {
        return 0.05 * v + 2.9;
    } else {
        return -0.1 * (v + 38) / (exp(-(v + 38) / 10) - 1);
    }
}

static inline double bm(double v) {
    return 4 * exp(-(v + 65) / 18);
}

static inline double ah(double v) {
    return 0.07 * exp(-(v + 63) / 20);
}

static inline double bh(double v) {
    return 1 / (1 + exp(-(v + 33) / 10));
}

// Saraga h-current (adapted by adriano)
static inline double rinf(double v) {
    return 1 / (1 + exp((v + 84) / 10.2));
}

static inline double taur(double v) {
    return 1 / (exp(-14.59 - 0.086 * v) + exp(-1.87 + 0.0701 * v));
}

// tau and inf functions

static inline double taun(double v) {
    return 1 / (an(v) + bn(v));
}

static inline double ninf(double v) {
    return an(v) / (an(v) + bn(v));
}

static inline double minf(double v) {
    return am(v) / (am(v) + bm(v));
}

static inline double hinf(double v) {
    return ah(v) / (ah(v) + bh(v));
}

static inline double tauh(double v) {
    return 1 / (ah(v) + bh(v));
}

static inline double taum(double v) {
    return 1 / (am(v) + bm(v));
}


// a, b for Ia is from Skinner
static inline double ainf(double v) {
    return 1 / (1 + exp(-(v + 14) / 16.6));
}

// minus sign wrong in paper
static inline double binf(double v) {
    return 1 / (1 + exp((v + 71) / 7.3));    
}

static inline double ab(double v) {
    return 0.000009 / (exp((v - 26) / 18.5));
}

static inline double bb(double v) {
    return 0.014 / (exp(-(v + 70) / 11) + 0.2);
}

static inline double taub(double v) {
    return 1 / (ab(v) + bb(v));
}

// H-current from Nancy model
/*
// h slow
static inline double hsinf(double v) {
    return 1 / (1 + exp((v + 71.3) / 7.9));
}

// h fast
static inline double hfinf(double v) {
    return 1 / (1 + exp((v + 79.2) / 9.78));
}

// h tau slow
static inline double tauhs(double v) {
    return 5.6 / (exp((v - 1.7) / 14) + exp(-(v + 260) / 43)) + 1;
}

// h tau fast
static inline double tauhf(double v) {
    return 0.51 / (exp((v - 1.7) / 10) + exp(-(v + 340) / 52)) + 1;
}
*/

OLM::OLM(double dd) {
    
    //dt is now a global variable that has the value of dd, which came from the 
    dt=dd;   
    
    //This is to initialize the vector and tell it how many values it should be filled with.
    y.push_back(V0);
    y.push_back(minf(V0));
    y.push_back(hinf(V0));
    y.push_back(ninf(V0));
    y.push_back(ainf(V0));
    y.push_back(binf(V0));
    y.push_back(rinf(V0));
    
    
    // y.push_back(0);
    // y.push_back(0);
    // y.push_back(0);
    // y.push_back(0);
    // y.push_back(0);
    // y.push_back(0);
    
    // cout << "y0 " << V << " y1 " << m << " y2 " << h << " y3 " << n << endl;
    // cout << "y4 " << a << " y5 " << b << " y6 " << r << endl;
    
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);


    // ornstein uhlenbeck stuff
    gavgi = 0.000001;
 /*  taui = 1.8;
    Di = 0.000003; */
    si = 0;
    Ei = -65;
    setDi(0.000003);
    setTaui(1.8);

    gavge = 0.000001;
/*    taue = 1.8;
    De = 0.000003;*/
    se = 0;
    Ee = 0;
    setDe(0.000003);
    setTaue(1.8);
 
    //Detection of Spike State and PSG
    detect = new SpikeDetect(-20, 2.0);
    
    //vars
    Gh = 12;
    Gl = 0.05;
    type = SuperCell::OCELL;
}

OLM::~OLM(void) {}


void OLM::derivs(void) {
    
    double J_L = Gl * (V - VL);
    double J_Na = (GNa * m * m * m * h) * (V - VNa);
    double J_K = GK * n * n * n * n * (V - VK);
    double J_H = Gh * r * (V - Vh);
    double J_A = Ga * a * b * (V - Va);

    dm = am(V) * (1 - m) - bm(V) * m;
    dh = ah(V) * (1 - h) - bh(V) * h;
    dn = an(V) * (1 - n) - bn(V) * n;
    
    // h-current
    dr = (rinf(V) - r) / taur(V);

    // a-current
    da = (ainf(V) - a) / 5;
    db = (binf(V) - b) / taub(V);
    
    // Current balance
    dV = 1.0 /Cm * (Iapp - J_Na - J_K - J_L - J_H - J_A); 
}


void OLM::setGh(double g) {
    Gh = g;
}

double OLM::getGh() {
    return Gh;
}
