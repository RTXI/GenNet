#ifndef LIFe_H
#define LIFe_H


#include <stdio.h>
#include "SuperCell.h"

using namespace std;


class LIFe : public SuperCell {
    
    public:
    
    LIFe(double dd);
    virtual ~LIFe(void);
    
    private:
    
    // solver- the main one is in SuperCell
    void derivs(void);
    
    double Cm, Rm, Vreset, Vrest, Vthresh, Vspike;
    
    int NOISE;
    
};
#endif //LIFe_H
