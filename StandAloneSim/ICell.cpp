

/**
* Gloveli et al. ICell
*/

#include <math.h> 
#include "ICell.h"

const double ICell::VNa = 50.0;
const double ICell::VK  = -90;
const double ICell::GNa = 100;
const double ICell::GK = 80.0;
const double ICell::Cm = 1.0;
const double ICell::VL = -67.0;
//const double ICell::GL = 0.1;
const double ICell::V0  = -65.0;

// macros -- soma and dendrites
#define V (y[0])
#define m (y[1])
#define h (y[2])
#define n (y[3])

#define dV (dydt[0])
#define dm (dydt[1])
#define dh (dydt[2])
#define dn (dydt[3])



/*******************
 * Model Functions *
 *******************/

static inline double am(double v)
{
  // linear approximation around points where am() is undefined
  if(fabs(v+54)<0.001) 
    return 1.28+0.16*(v+54);
  else
    return 0.32*(54+v)/(1-exp(-(v+54)/4));
}

static inline double bm(double v)
{
  if(fabs(v+27)<0.001)
    return 1.4-0.14*(v+27);
  else
    return 0.28*(v+27)/(exp((v+27)/5)-1);
}

static inline double ah(double v)
{
  return 0.128*exp(-(50+v)/18);
}

static inline double bh(double v) 
{
  return 4/(1+exp(-(v+27)/5));
}

static inline double an(double v)
{
  if(fabs(v+52)<0.001)
    return 0.16+0.016*(v+52);
  else
    return .032*(v+52)/(1-exp(-(v+52)/5));
}

static inline double bn(double v)
{
  return 0.5*exp(-(57+v)/40);
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

ICell::ICell(double dd) {
    
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
    Gl = 0.1;
    type = SuperCell::ICELL;
    
}

ICell::~ICell(void) {}

void ICell::derivs(void) {
    
    double J_L=Gl*(V-VL);
    double J_Na=(GNa*m*m*m*h)*(V-VNa);
    double J_K=GK*n*n*n*n*(V-VK);

    
    dm=am(V)*(1-m)-bm(V)*m;
    dh=ah(V)*(1-h)-bh(V)*h;
    dn=an(V)*(1-n)-bn(V)*n;
    dV=1.0/Cm*(Iapp - J_Na - J_K - J_L);

    
//    cout << V << " " << m << " " << h << " " << n << " " << dV << " " << J_L << " " << J_Na << " " << J_K << endl;

}
