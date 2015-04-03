#ifndef IZTonic_H
#define IZTonic_H


#include <stdio.h>
#include "SuperCell.h"

using namespace std;


class IZTonic : public SuperCell {
    
    public:
    
    IZTonic(double dd);
    virtual ~IZTonic(void);
    
    private:
    
    // solver- the main one is in SuperCell
    void derivs(void);
    
    double a,b,c,d;
    
    int NOISE;
    
};
#endif //IZTonic_H
