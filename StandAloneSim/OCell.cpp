/**

* OCell model--made a child class of SuperCell. updated 6-27-2007 by Pratik Randeria.
*/


#include <math.h> 
#include "OCell.h"

const double OCell::VNa =  55.0;
const double OCell::GNa =  52.0;
const double OCell::VK  = -90.0;
const double OCell::GK  =  30.0;
const double OCell::VL  = -65.0;
//const double OCell::GL  = 0.5;
const double OCell::Va  =-100.0;
const double OCell::Ga  =   3.0;
const double OCell::Vh  = -20.0;
const double OCell::GNap=   0.5;
const double OCell::Cm  =   1.5;
const double OCell::V0 = -65.0;

#define stellate 0

// macros -- soma and dendrites
#define V (y[0])
#define m (y[1])
#define h (y[2])
#define n (y[3])
#define a (y[4])    
#define b (y[5])
#define hf (y[6])
#define hs (y[7])
#define mnap (y[8])

// derivs
#define dV (dydt[0])
#define dm (dydt[1])
#define dh (dydt[2])
#define dn (dydt[3])
#define da (dydt[4])
#define db (dydt[5])
#define dhf (dydt[6])
#define dhs (dydt[7])
#define dmnap (dydt[8])


/*******************
 * Model Functions *
 *******************/
 
static inline double an(double v) {
//return -0.01 * (v + 27) / (exp(-0.1 * (v + 27)) - 1);
    return -0.01 * (v + 27) / (exp(-0.1 * (v + 27)) - 1);
}

static inline double bn(double v) {
    return 0.125 * exp(-(v + 37) / 80);
}

static inline double am(double v) {
    return -0.1 * (v + 23) / (exp(-0.1 * (v + 23)) - 1);
}

static inline double bm(double v) {
    return 4 * exp(-(v + 48) / 18);
}

static inline double ah(double v) {
    return 0.07 * exp(-(v + 37) / 20);
}

static inline double bh(double v) {
    return 1 / (exp(-0.1 * (v + 7)) + 1);
}

static inline double ap(double v) {
    return 1 / 0.15 / (1 + exp(-(v + 38) / 6.5));
}

static inline double bp(double v) {
    return exp(-(v + 38) / 6.5) / 0.15 / (1 + exp(-(v + 38) / 6.5));
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

static inline double mnapinf(double v) {
    return ap(v) / (ap(v) + bp(v));
}

// a, b for Ia is from Skinner
static inline double ainf(double v) {
    return 1 / (1 + exp(-(v + 14) / 16.6));
}

static inline double binf(double v) {
    return 1 / (1 + exp((v + 71) / 7.3));    ////// minus sign wrong in paper (don't need it)??
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

OCell::OCell(double dd) {
    
    //dt is now a global variable that has the value of dd, which came from the 
    dt=dd;   
    
    //This is to initialize the vector and tell it how many values it should be filled with.
    y.push_back(V0);
    y.push_back(minf(V0));
    y.push_back(hinf(V0));
    y.push_back(ninf(V0));
    y.push_back(ainf(V0));
    y.push_back(binf(V0));
    y.push_back(hfinf(V0));
    y.push_back(hsinf(V0));
    y.push_back(mnapinf(V0));
    
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
 
    //Detection of Spike State and PSG
    detect = new SpikeDetect(-20, 2);
    
    //vars
    Gh =1.5;
    Gl = 0.5;
    type = SuperCell::OCELL;
}

OCell::~OCell(void) {}


void OCell::derivs(void) {
    
    double J_L = Gl * (V - VL);
    double J_Na = (GNa * m * m * m * h) * (V - VNa);
    double J_K = GK * n * n * n * n * (V - VK);
    double J_H = Gh * (0.65 * hf + 0.35 * hs) * (V - Vh);

#ifdef stellate
    double J_Nap = GNap * mnap * (V - VNa);
#else
    double J_A = Ga * a * b * (V - Va);
#endif

    dm = am(V) * (1 - m) - bm(V) * m;
    dh = ah(V) * (1 - h) - bh(V) * h;
    //dn = an(V) * (1 - n) - bn(V) * n;
    dn = (ninf(V)- n) / taun(V);
    
    // h-current
    
    dhf = (hfinf(V) - hf) / tauhf(V);
    dhs = (hsinf(V) - hs) / tauhs(V);

#ifdef stellate
    // nap current
    dmnap = ap(V) * (1 - mnap) - bp(V) * mnap;

    // Stellate Cell
    dV = 1.0 /Cm * (Iapp - J_Na - J_K - J_L - J_H - J_Nap);
#else    
    // a-current
    da = (ainf(V) - a) / 5;
    db = (binf(V) - b) / taub(V);
    
    // O-LM Cell
    dV = 1.0 /Cm * (Iapp - J_Na - J_K - J_L - J_H - J_A); 
#endif
}


void OCell::setGh(double g) {
    Gh = g;
}

double OCell::getGh() {
    return Gh;
}

double OCell::getHfHs() {
    return 0.65 * hf + 0.35 * hs;
}
