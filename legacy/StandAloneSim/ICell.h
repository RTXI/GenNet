
#ifndef ICELL_H
#define ICELL_H


#include "SuperCell.h"
#include <stdio.h>

using namespace std;


class ICell : public SuperCell {
    
    public:
    
    ICell(double dd);
    virtual ~ICell(void);
   
    private:
    
    // solver- the main one is in SuperCell
    void derivs(void);        
    
    // Model Parameters 
    static const double VNa,VK,GNa,GK,Cm;
    static const double VL;//,GL;
    static const double V0;
    
};
#endif //ICELL_H
