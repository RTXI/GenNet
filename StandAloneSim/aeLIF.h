#ifndef aeLIF_H
#define aeLIF_H


#include <stdio.h>
#include "SuperCell.h"

using namespace std;


class aeLIF : public SuperCell {
    
    public:
    
    aeLIF(double dd);
    virtual ~aeLIF(void);
    
    private:
    
    // solver- the main one is in SuperCell
    void derivs(void);
    
    double Cm, Rm, El, Vt, Vspk, deltT, a, b, tauw;
    double aa, bb;
    double tauww;
    int NOISE;
    
};
#endif //aeLIF_H
