#ifndef IZClass1_H
#define IZClass1_H


#include <stdio.h>
#include "SuperCell.h"

using namespace std;


class IZClass1 : public SuperCell {
    
    public:
    
    IZClass1(double dd);
    virtual ~IZClass1(void);
    
    private:
    
    // solver- the main one is in SuperCell
    void derivs(void);
    
    double a,b,c,d;
    
    int NOISE;
    
};
#endif //IZClass1_H
