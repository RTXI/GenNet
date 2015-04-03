

/**
 * Wang Buzsaki model from 1996 paper
 */
#include <math.h> 
#include "WangBuzsaki.h"

// Wang Buzsaki syns
//const double WangBuzsaki::psgrise = 1;
//const double WangBuzsaki::psgfall = 12;

// these syns are from Jonas
//const double WangBuzsaki::psgrise = 0.16;
//const double WangBuzsaki::psgfall = 1.2;

const double WangBuzsaki::VNa = 55.0;
const double WangBuzsaki::VK  = -90;
const double WangBuzsaki::GNa = 35;
const double WangBuzsaki::GK = 9.0;
const double WangBuzsaki::Cm = 1.0;
const double WangBuzsaki::VL = -65.0;
const double WangBuzsaki::GL = 0.1;
const double WangBuzsaki::V0  = -65.0;

// macros -- soma and dendrites
#define V (y[0])
#define m (y[1])
#define h (y[2])
#define n (y[3])

#define dV (dydt[0])
#define dm (dydt[1])
#define dh (dydt[2])
#define dn (dydt[3])


static inline double am(double v) {
    return -0.1 * (v + 35) / (exp(-0.1 * (v + 35)) - 1);
}

static inline double bm(double v)
{
    return 4 * exp(-(v + 60) / 18);
}

static inline double ah(double v)
{
    return 0.07 * exp(-(v + 58) / 20);
}

static inline double bh(double v) 
{
    return 1 / (exp(-0.1 * (v + 28)) + 1);
}

static inline double an(double v)
{
    return -0.01 * (v + 34) / (exp(-0.1 * (v + 34)) - 1);
}

static inline double bn(double v)
{
    return 0.125 * exp(-(v + 44) / 80);
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

WangBuzsaki::WangBuzsaki(double dd) {
    
    //dt is now a global variable that has the value of dd, which came from the 
    dt=dd;
    
    //This is to initialize the vector and tell it how many values it should be filled with.
    y.push_back(-65.0);
    y.push_back(minf(V0));
    y.push_back(hinf(V0));
    y.push_back(ninf(V0));
      
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
  
    //Detection of Spike State and PSG
    detect = new SpikeDetect(-20, 2);

    type = SuperCell::ICELL;
}

WangBuzsaki::~WangBuzsaki(void) {}


void WangBuzsaki::derivs(void) {
    
    double J_L=GL*(V-VL);
    double J_Na=(GNa*minf(V)*minf(V)*minf(V)*h)*(V-VNa);
    double J_K=GK*n*n*n*n*(V-VK);
    
    dh = 5 * (ah(V) * (1 - h) - bh(V) * h);
    dn = 5 * (an(V) * (1 - n) - bn(V) * n);
    
    dV=1.0/Cm*(Iapp - J_Na - J_K - J_L);
}
