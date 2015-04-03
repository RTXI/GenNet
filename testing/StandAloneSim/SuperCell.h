
#ifndef SUPERCELL_H
#define SUPERCELL_H

#include <stdio.h>
#include <vector>
#include "SpikeDetect.h"
#include "PSG.h"
#include <math.h>

using namespace std;

class SuperCell
{

    public: 
    SuperCell();
    virtual ~SuperCell();
    double normRand(void);
    void execute(double);
    virtual void derivs(void) = 0;
    void solve(void);
    void setVoltage(double);

    void setnegT(double nt);
    double getnegT();

    void setDi(double d);
    void setDe(double d);
    void setTaui(double t);
    void setTaue(double t);
    void setGavgi(double g);
    void setGavge(double g);

    void setGl(double g);

    vector<double> y;
    vector<double> dydt;
    
    void ChangeDT(double);
    int getType();
    double getVoltage(); 
    
    double getPSG();
    double dt;
    int type;
    
    double negT, Di, De, taui, taue, Ai, Ae;
    double gavgi, gavge, si, se, Ee, Ei;
    double Gl;
    
    // spike detector 
    SpikeDetect *detect;
    
    // psg
    PSG *psg1;
    
    double Gout; //This is the synaptic output conductance.
    double Iapp;
    
    //const int ECELL, ICELL, OCELL;
    static const int ECELL = 0;
    static const int ICELL = 1;
    static const int OCELL = 2;
    static const int MSPYCELL = 8;
    static const int FSCELL = 9;
    static const int LIFE = 10;
    static const int LIFI = 11;
};


#endif //SUPERCELL_H

