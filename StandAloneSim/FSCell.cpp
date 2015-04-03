/**
*  PYCell model based on model from Mainen and Sejnowski, 1996
*  Has optional noise parameter
*/


#include <math.h> 
#include "FSCell.h"


const double FSCell::radius = 22.0; // um
const double FSCell::SA = 4 * 3.14159 * radius * radius * 1.0e-8*1e3; //in mm^2

const double FSCell::Gna = 112.5 *1.2* SA; // uS
const double FSCell::Gkv  =  225.0*3 * SA;
//const double FSCell::Gl  =   2.0 * SA;
const double FSCell::Gkd = .30 * SA;

const double FSCell::Ena =  50.0;
const double FSCell::Ek = -70.0;
const double FSCell::El  = -65.0;

const double FSCell::Cm = 1.2*(4*3.14159*radius*radius*1.0e-8)*1.0e3; //convert to nF
const double FSCell::V0  = -70.0;



// macros -- soma
#define V (y[0])
//#define m (y[1])
#define n (y[1])
#define h (y[2])
#define mkd (y[3])
#define hkd (y[4])


// macros derivatives
#define dV (dydt[0])
//#define dm (dydt[1])
#define dn (dydt[1])
#define dh (dydt[2])
#define dmkd (dydt[3])
#define dhkd (dydt[4])

    

FSCell::FSCell(double dd) {
    
    //dt is now a global variable that has the value of dd, which came from the HybridNetwork period (1000.0/rate)
    dt=dd;
    
    //This is to initialize the vector and tell it how many values it should be filled with.
    y.push_back(V0);
  //  y.push_back(minf(V0));
    y.push_back(ninf(V0));
    y.push_back(hinf(V0));
    y.push_back(mkdinf(V0));
    y.push_back(hkdinf(V0));

    

    dydt.push_back(0);
   // dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    
    //Detection of Spike State and PSG
    detect = new SpikeDetect(-20, 2);

    Gl = 0.02; //uS
    
    // ornstein uhlenbeck stuff
    gavgi = 0.000003;
    setTaui(4.0);
    setDi(0.00001);
    si = 0;
    Ei = -75;
    
    gavge = 0.000003;
    setTaue(4);
    setDe(0.00001);
    se = 0;
    Ee = 0;

    Ioff = Gna * minf(V0) * minf(V0) * minf(V0) * hinf(V0) * (V0 - Ena) +
           Gkv * ninf(V0) * ninf(V0) * (V0 - Ek) + 
           Gkd * mkdinf(V0) * mkdinf(V0) * mkdinf(V0)  * hkdinf(V0) * (V0 - Ek);
    
    NOISE = 1;
    
    type = SuperCell::FSCELL;
}

//Destructor
FSCell::~FSCell(void) {}

/**
* Kinetic Functions
*/



//double FSCell::taum (double v) {
//   return 1.0;
//}

double FSCell::taun (double v) {
   // return (0.087+3.4/(1.0+exp((v+7.6)/8.6)))*(0.087+11.4/(1.0+exp(-(v-13.0)/18.7)));
//    return (0.087+11.4/(1.0+exp((v+14.6)/8.6)))*(0.087+11.4/(1.0+exp(-(v-1.30)/18.7)));
    return (0.087+11.4/(1.0+exp((v+14.6)/8.6)))*(0.087+11.4/(1.0+exp(-(v-13.0)/18.7)))*(1+((v+40)/80)*(v<-40));
}

double FSCell::tauh (double v) {
    return 0.5+14.0/(1.0+exp(-(v+60.0)/-12.0));
   // return 0.5+14.0/(1.0+exp(-(v+60.0)/-12.0));
}

double FSCell::taumkd (double v) {
    return 2;
   // return 0.5+30.0/(1.0+exp(-(v+70.0)/4.0));
}

double FSCell::tauhkd (double v) {
    return 150.0;
}



double FSCell::minf (double v) {
    return 1.0/(1.0+exp(-(v+24.0)/11.5));
}

double FSCell::ninf (double v) {
  //  return 1.0/(1.0+exp(-(v+12.4)/6.8));
    return 1.0/(1.0+exp(-(v+1.24)/9.8));
}

double FSCell::hinf (double v) {

    return 1.0/(1.0+exp(-(v+58.3)/-6.7));
   // return 1.0/(1.0+exp(-(v+58.3)/-6.7));
}


double FSCell::mkdinf (double v) {
    return 1.0/(1.0+exp(-(v+50.0)/20.0));
}

double FSCell::hkdinf (double v) {
    return 1.0/(1.0+exp(-(v+70.0)/-6.0));
}






void FSCell::derivs(void) {
   
    double Ina, Ikv, Il, Ikd, m;
    Ina = 0;
    Ikv = 0;
    Il = 0;
    Ikd = 0;

    m = minf(V);
   // dm = (minf(V) - m) / taum(V);
    dh = (hinf(V) - h) / tauh(V);
    dn = (ninf(V) - n) / taun(V);
    dmkd = (mkdinf(V) - mkd) / taumkd(V);
    dhkd = (hkdinf(V) - hkd) / tauhkd(V);
    
    Ina = Gna * m * m * m * h * (V - Ena);
    Ikv = Gkv * n * n * (V - Ek); 
//    Il = Gl * (V + V0) - 2 * Gl * El; //This is to remove additional offset not compensated for already
Il = Gl * (V - V0);

    Ikd = Gkd * mkd * mkd * mkd  * hkd * (V - Ek);


    
    if (NOISE) {
        
        se = (gavge + (se - gavge) * exp(-dt / taue) + Ae * (((double)rand()/RAND_MAX)-0.5));
        si = (gavgi + (si - gavgi) * exp(-dt / taui) + Ai * (((double)rand()/RAND_MAX)-0.5));
        
        if (se < 0) se=0;
        if (si < 0) si=0;
        
        double Ii = si * (V - Ei);
        double Ie = se * (V - Ee);
        
        
        dV = (Iapp/1000 - Ina - Ikv - Ikd - Il - Ii - Ie + Ioff) / Cm;
    }
    else {
//	cout <<Ikv << " " << Ica << endl;
        dV = (Iapp/1000 - Ina - Ikv - Ikd - Il - 0.05) / Cm;
    }
}
