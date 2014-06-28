
#ifndef WANGBUZSAKI_H
#define WANGBUZSAKI_H


#include "SuperCell.h"
#include <stdio.h>

using namespace std;


class WangBuzsaki : public SuperCell {
    
    public:
    
    WangBuzsaki(double dd);
    virtual ~WangBuzsaki(void);
   
    private:
    
    // solver- the main one is in SuperCell
    void derivs(void);        
    
    // Model Parameters 
    static const double VNa,VK,GNa,GK,Cm;
    static const double VL,GL;
    static const double V0;
};
#endif
