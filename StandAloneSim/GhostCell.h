#ifndef GHOSTCELL_H
#define GHOSTCELL_H


#include <stdio.h>
#include "SuperCell.h"

using namespace std;


class GhostCell : public SuperCell {
    
    public:
    
    GhostCell(double dd);
    virtual ~GhostCell(void);
    
    void out(double);
    
   
    private:
    
    // solver- the main one is in SuperCell
    void derivs(void);        
    
//    static const double GL;
    static const double EL;
    static const double Cm;
    
    // synaptic kinetics
    static const double psgrise;
    static const double psgfall;
	
    
};

#endif //GHOSTCELL_H
