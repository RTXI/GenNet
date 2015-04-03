#ifndef OLM_H
#define OLM_H

#include <stdio.h>
#include "SuperCell.h"

using namespace std;



class OLM : public SuperCell {
    
    public:
    
    OLM(double dd);
    virtual ~OLM(void);
    
    void setGh(double g);
    double getGh();

    double getHfHs();

    private:
    

    void derivs(void);


    // Model Parameters 
    static const double VNa, GNa;
    static const double VK, GK;
    static const double VL;// GL;
    static const double Va, Ga;
    static const double Vh;
    static const double GNap;

    // this is not constant since we want to change it at runtime 
    double Gh;

    static const double Cm;
    static const double V0;
};

#endif

