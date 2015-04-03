#ifndef MSPYCELL_H
#define MSPYCELL_H

#include <stdlib.h>
#include <stdio.h>
#include "SuperCell.h"

using namespace std;


class MSPyCell : public SuperCell {

    public:

    MSPyCell(double dd);
    virtual ~MSPyCell(void);

    void out(double);


    private:

    // solver- the main one is in SuperCell
    void derivs(void);

    // helper functions
    double am(double);
    double bm(double);
    double an(double);
    double bn(double);
    double ah(double);
    double bh(double);

    double amca(double);
    double bmca(double);
    double amkm(double);
    double bmkm(double);
    double amkca(double);
    double bmkca(double);

    double taum(double);
    double taun(double);
    double tauh(double);
    double taumca(double);
    double taumkm(double);
    double taumkca(double);

    double minf(double);
    double ninf(double);
    double hinf(double);
    double mcainf(double);
    double mkminf(double);
    double mkcainf(double);


   // fixed parameters
    static const double Gna;
    static const double Gkv;
   // static const double Gl;
    static const double Gca;
    static const double Gkm;
    static const double Gkca;

    static const double Ena;
    static const double Ek;
    static const double El;
    static const double Eca;

    static const double Cm;
    static const double V0;

    static const double Ca_inf;
    static const double alpha_Ca;
    static const double tau_Ca;
    static const double SA;
    static const double radius;

    // Ornstein Uhlenbeck noise
    double xxx, yyy, zzz;
    int NOISE;
};

#endif //ECELL_H



































