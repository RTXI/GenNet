#ifndef FSCELL_H
#define FSCELL_H

#include <stdlib.h>
#include <stdio.h>
#include "SuperCell.h"

using namespace std;


class FSCell : public SuperCell {

    public:

    FSCell(double dd);
    virtual ~FSCell(void);

    void out(double);


    private:

    // solver- the main one is in SuperCell
    void derivs(void);

    // helper functions
//    double taum(double);
    double taun(double);
    double tauh(double);
    double taumkd(double);
    double tauhkd(double);

    double minf(double);
    double ninf(double);
    double hinf(double);
    double mkdinf(double);
    double hkdinf(double);


   // fixed parameters
    static const double Gna;
    static const double Gkv;
    //static const double Gl;
    static const double Gkd;

    static const double Ena;
    static const double Ek;
    static const double El;

    static const double Cm;
    static const double V0;

    static const double SA;
    static const double radius;
   
    double Ioff;

    // Ornstein Uhlenbeck noise
    int NOISE;
};

#endif //FSCELL_H



































