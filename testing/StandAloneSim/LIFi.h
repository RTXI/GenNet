#ifndef LIFi_H
#define LIFi_H


#include <stdio.h>
#include "SuperCell.h"

using namespace std;


class LIFi : public SuperCell {
    
    public:
    
    LIFi(double dd);
    virtual ~LIFi(void);
    
    private:
    
    // solver- the main one is in SuperCell
    void derivs(void);
    
    double Cm, Rm, Vreset, Vrest, Vthresh, Vspike;
    
    int NOISE;
    
};
#endif //LIFi_H
