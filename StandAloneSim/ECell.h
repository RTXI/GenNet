#ifndef ECELL_H
#define ECELL_H


#include <stdio.h>
#include "SuperCell.h"

using namespace std;


class ECell : public SuperCell {
    
    public:
    
    ECell(double dd);
    virtual ~ECell(void);
    
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
    double taum(double);
    double taun(double);
    double tauh(double);
    double minf(double);
    double ninf(double);
    double hinf(double);
    
    // fixed parameters
    static const double GNa;
    static const double GK;
//    static const double GL;
    
    static const double ENa;
    static const double EK;
    static const double EL;
    
    static const double Cm;
    
    static const double V0;
    
    // Ornstein Uhlenbeck noise
    int NOISE;
};

#endif //ECELL_H
