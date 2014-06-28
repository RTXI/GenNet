/**
*  PYCell model based on model from Mainen and Sejnowski, 1996
*  Has optional noise parameter
*/


#include <math.h> 
#include "MSPyCell.h"


const double MSPyCell::radius = 40; // um
const double MSPyCell::SA = 4 * 3.14159 * radius * radius * 1e-6; //in um^2

const double MSPyCell::Gna = 600.0 * SA; // uS
const double MSPyCell::Gkv  =  75.0 * SA;
//const double MSPyCell::Gl  =   1.2 * SA;
const double MSPyCell::Gca = 0.6 * SA;
const double MSPyCell::Gkm = 8 * SA;
const double MSPyCell::Gkca = 30 * SA;
/*
const double MSPyCell::Gna = 00.0 * SA; // uS
const double MSPyCell::Gkv  =  0.0 * SA;
const double MSPyCell::Gl  =   0.2 * SA;
const double MSPyCell::Gca = 0.0 * SA;
const double MSPyCell::Gkm = 0.0 * SA;
const double MSPyCell::Gkca = 0.0 * SA;
*/
const double MSPyCell::Ena =  50.0;
const double MSPyCell::Ek = -75.0;
const double MSPyCell::El  = -70.0;
const double MSPyCell::Eca = 250;

const double MSPyCell::Cm = 1.0*(4*3.14159*radius*radius*1e-8)*1e3; //convert to nF
const double MSPyCell::V0  = -70.0;

const double MSPyCell::Ca_inf = 0.00025;
const double MSPyCell::alpha_Ca = -5.1822;
const double MSPyCell::tau_Ca = 300;





// macros -- soma
#define V (y[0])
#define m (y[1])
#define n (y[2])
#define h (y[3])
#define mca (y[4])
#define mkm (y[5])
#define mkca (y[6])
#define Ca (y[7])


// macros derivatives
#define dV (dydt[0])
#define dm (dydt[1])
#define dn (dydt[2])
#define dh (dydt[3])
#define dmca (dydt[4])
#define dmkm (dydt[5])
#define dmkca (dydt[6])
#define dCa (dydt[7])

    







MSPyCell::MSPyCell(double dd) {
    
    //dt is now a global variable that has the value of dd, which came from the HybridNetwork period (1000.0/rate)
    dt=dd;
    
    //This is to initialize the vector and tell it how many values it should be filled with.
    y.push_back(V0);
    y.push_back(minf(V0));
    y.push_back(ninf(V0));
    y.push_back(hinf(V0));
    y.push_back(mcainf(V0));
    y.push_back(mkminf(V0));
    y.push_back(mkcainf(Ca_inf));
    y.push_back(Ca_inf);

    
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);
    dydt.push_back(0);

    //Detection of Spike State and PSG
    detect = new SpikeDetect(-20, 2.0);

    Gl = 0.024; 
    
    // ornstein uhlenbeck stuff
    gavgi = 0.00001;
    setTaui(1.8);
    setDi(0.0004);
    si = 0;
    Ei = -65;
    
    gavge = 0.00001;
    setTaue(1.8);
    setDe(0.0004);
    se = 0;
    Ee = 0;
    
    NOISE = 1;
    
    type = SuperCell::MSPYCELL;
}

//Destructor
MSPyCell::~MSPyCell(void) {}

/**
* Kinetic Functions
*/

double MSPyCell::am (double v) {
	xxx = (v+30);
	yyy = 9;
	zzz = 0.182;
	if (fabs(xxx/yyy) < 1e-6) {
		return zzz*yyy*(xxx/yyy/2+1);
	} else {
		return zzz*xxx/(1-exp(-xxx/yyy));
	}
}



double MSPyCell::bm (double v) {
	xxx = (v+25);
	yyy = 9;
	zzz = -0.124;
	if (fabs(xxx/yyy) < 1e-6) {
		return zzz*yyy*(xxx/yyy/2-1);
	} else {
		return zzz*xxx/(1-exp(xxx/yyy));
	}
}



double MSPyCell::ah (double v) {
	xxx = (v+40);
	yyy = 5*2;
	zzz = 0.024;
	if (fabs(xxx/yyy) < 1e-6) {
		return zzz*yyy*(1 + xxx/yyy/2);
	} else {
		return zzz*xxx/(1-exp(-xxx/yyy));
	}

}



double MSPyCell::bh (double v) {
	xxx = (v+65);
	yyy = 5*2;
	zzz = -0.0091;
	if (fabs(xxx/yyy) < 1e-6) {
		return zzz*yyy*(xxx/yyy/2-1);
	} else {
		return zzz*xxx/(1 - exp(xxx/yyy));
	}

}

double MSPyCell::an (double v) {
	xxx = (v-25);
	yyy = 8;
	zzz = 0.02;  
	if (fabs(xxx/yyy) < 1e-6) {
		return zzz*yyy*(1 + xxx/yyy/2);
	} else {
		return zzz*xxx/(1-exp(-xxx/yyy));
	}
}

double MSPyCell::bn (double v) {
	xxx = (v-25);
	yyy = 8; 
	zzz = -0.002; 
	if (fabs(xxx/yyy) < 1e-6) {
		return zzz*yyy*(xxx/yyy/2-1);
	} else {
		return zzz*xxx/(1-exp(xxx/yyy));
	}
}


double MSPyCell::amkm (double v) {
	xxx = (v+30);
	yyy = 7.5;
	zzz = 1e-4;  
	if (fabs(xxx/yyy) < 1e-6) {
		return zzz*yyy*(1 + xxx/yyy/2);
	} else {
		return zzz*xxx/(1-exp(-xxx/yyy));
	}
}

double MSPyCell::bmkm (double v) {
	xxx = (v+30);
	yyy = 7.5; 
	zzz = -1.1e-4; 
	if (fabs(xxx/yyy) < 1e-6) {
		return zzz*yyy*(xxx/yyy/2-1);
	} else {
		return zzz*xxx/(1-exp(xxx/yyy));
	}
}


double MSPyCell::amca (double v) {
	return 5*4.57e-4*exp((v+13)/20);
}

double MSPyCell::bmca (double v) {
	return 10*0.0065/(1 + exp((v+15)/28));
}


double MSPyCell::amkca (double ca) {
	return 0.05*ca;
}

double MSPyCell::bmkca (double ca) {
	return 0.02;
}





double MSPyCell::taum (double v) {
	return 1.0 / (am(v) + bm(v));
}

double MSPyCell::taun (double v) {
    return 1.0 / (an(v) + bn(v));
}

double MSPyCell::tauh (double v) {
    return 1.0 / (ah(v) + bh(v));
}
double MSPyCell::taumca (double v) {
	return 1.0 / (amca(v) + bmca(v));
}

double MSPyCell::taumkm (double v) {
    return 0.05 / (amkm(v) + bmkm(v));
// Modified here
}
double MSPyCell::taumkca (double v) {
    return 1.0 / (amkca(v) + bmkca(v));
}



double MSPyCell::minf (double v) {
    return am(v) / (am(v) + bm(v));
}

double MSPyCell::ninf (double v) {
    return an(v) / (an(v) + bn(v));
}

double MSPyCell::hinf (double v) {
    return 1.0/(1.0+exp((v+55)/6.2));
}



double MSPyCell::mcainf (double v) {
    return amca(v) / (amca(v) + bmca(v));
}

double MSPyCell::mkminf (double v) {
    return amkm(v) / (amkm(v) + bmkm(v));
}

double MSPyCell::mkcainf (double v) {
    return amkca(v) / (amkca(v) + bmkca(v));
}





void MSPyCell::derivs(void) {
   
    double Ina, Ikv, Il, Ica, Ikm, Ikca = 0;
Ina = 0;
Ikv = 0;
Il = 0;
Ica = 0;
Ikm = 0;
Ikca = 0;
    dm = (minf(V) - m) / taum(V);
    dh = (hinf(V) - h) / tauh(V);
    dn = (ninf(V) - n) / taun(V);
    dmca = (mcainf(V) - mca) / taumca(V);
    dmkm = (mkminf(V) - mkm) / taumkm(V);
    dmkca = (mkcainf(Ca) - mkca) / taumkca(Ca);
    
    Ina = Gna * m * m * m * h * (V - Ena);
    Ikv = Gkv * n * (V - Ek); 
    Il = Gl * (V - El); 
    Ica = Gca * mca * mca * mca * (V - Eca);
    Ikm = Gkm * mkm * (V - Ek);
    Ikca = Gkca * mkca * (V - Ek);
//cout << "Na " << Ina << "  Ikv " << Ikv << "  Ikm " << Ikm << "  Il " << Il << "  Ica " << Ica << "  Ikca " << Ikca << endl;


    dCa = alpha_Ca*Ica - (Ca - Ca_inf)/tau_Ca;
    
    if (NOISE) {
        se = (gavge + (se - gavge) * exp(-dt / taue) + Ae * (((double)rand()/RAND_MAX)-0.5));
        si = (gavgi + (si - gavgi) * exp(-dt / taui) + Ai * (((double)rand()/RAND_MAX)-0.5));
        
        if (se < 0) se=0;
        if (si < 0) si=0;
        
        double Ii = si * (V - Ei);
        double Ie = se * (V - Ee);
        
        
        dV = (Iapp/1000 - Ina - Ikv - Ica - Ikm - Ikca - Il - Ii - Ie) / Cm;
    }
    else {
//	cout <<Ikv << " " << Ica << endl;
        dV = (Iapp/1000 - Ina - Ikv - Ica - Ikm - Ikca - Il) / Cm;
    }
}
