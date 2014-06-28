#include <math.h>
#include "SuperCell.h"
#include <iostream>
#include <stdlib.h>

using namespace std;

//This is the macro of V
#define V (y[0])

SuperCell::SuperCell()
{
    Iapp=-6.66;
    Gout = 0.0;
    type = -1;
    negT = 0;

    // ornstein uhlenbeck stuff
    Di = 0.0;
    De = 0.0;
    Ai = 0.0;
    Ae = 0.0;
    taui = 1.0;
    taue = 1.0;
    gavgi = 0.000001;
    si = 0;
    Ei = -65;
    gavge = 0.000001;
    se = 0;
    Ee = 0;

    Gl = 0.0;




}

SuperCell::~SuperCell() {}


double SuperCell::normRand() {
    //Implementation of Box-Mueller algorithm from numerical recipes
    static int iset=0;
    static double gset;
    double fac, rsq, v1, v2;
    
    if (iset==0) {
        do {
            v1 = 2.0*((double)rand()/RAND_MAX) - 1.0;
            v2 = 2.0*((double)rand()/RAND_MAX) - 1.0;
            rsq = v1*v1 + v2*v2;
            
        } while (rsq >=1.0);
        fac = sqrt(-2.0*log(rsq)/rsq);
        gset = v1*fac;
        iset = 1;
        return v2*fac;
    } else {
        iset = 0;
        return gset;
    }
}

/* inline double SuperCell::getVoltage() {
    //cout << " V: " << V << endl;
    return V;
}*/


double SuperCell::getnegT() {
    return negT;
}
void SuperCell::setnegT(double nt) {
    negT = nt;
}



void SuperCell::setDe(double d) {
    De = d;
    Ae = sqrt((De * taue / 2) * (1 - exp(-2 * dt / taue)));
}
void SuperCell::setDi(double d) {
    Di = d;
    Ai = sqrt((Di * taui / 2) * (1 - exp(-2 * dt / taui)));
}
void SuperCell::setTaue(double t) {
    taue = t;
    Ae = sqrt((De * taue / 2) * (1 - exp(-2 * dt / taue)));
}
void SuperCell::setTaui(double t) {
    taui = t;
    Ai = sqrt((Di * taui / 2) * (1 - exp(-2 * dt / taui)));
}

void SuperCell::setGl(double g) {
    Gl = g;
}


void SuperCell::setGavgi(double g) {
    gavgi = g;
}


void SuperCell::setGavge(double g) {
    gavge = g;
}



void SuperCell::ChangeDT(double d) {
   dt = d;
   psg1->setDt(d);
}


double SuperCell::getPSG() {
    //cout << " Gout: " << Gout << endl;
    return Gout;
}

void SuperCell::setVoltage(double newVolt) {
    V = newVolt;
}


double SuperCell::getVoltage() {
    return V;
   
}

void SuperCell::execute(double II) 
{
    Iapp=II;
    solve();
    
    //update the spike detector's state
    detect->update(V, dt);
}




//Simple Euler's Solver
void SuperCell::solve() 
{

    derivs();
    
    for(unsigned int i = 0; i < y.size();++i) 
    {
        y[i] += dt*dydt[i];
    }
}

 
/*
void SuperCell::solve() {
    //  num vars

    unsigned int i;
    
    double h = dt;
    double hh = h*0.5;

    double h6 = h/6.0;

    vector<double> dym, dyt, yinit, yt, dydt_init;
    yinit = y;
    yt = y;


    derivs();
    dydt_init = dydt;
    for (i=0; i<y.size(); i++) {
	    yt[i]=y[i]+hh*dydt[i];
    }
    y = yt;
    derivs();
    dyt = dydt;

    for (i=0; i<y.size(); i++) {
           yt[i]=yinit[i]+hh*dyt[i];
    }

    y=yt;
    derivs();
    dym = dydt;
    
    for (i=0; i<y.size(); i++) {
	    yt[i] = yinit[i] + h*dym[i];
	    dym[i] += dyt[i];
    }
    y = yt;
    derivs();
    dyt = dydt;

    for (i=0; i<y.size(); i++) {
            y[i] = yinit[i]+h6*(dydt_init[i]+dyt[i]+2.0*dym[i]);
    }
    derivs();


}*/





int SuperCell::getType() {
	return type;
}

