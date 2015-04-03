
#ifndef SYNAPSE_H
#define SYNAPSE_H

#include "PSG.h"

using namespace std;

class Synapse {
    
    public:
    
        Synapse(double, int, int, double, double, int, int);

        virtual ~Synapse(void);
        
        inline int getPost() { return post; };
        inline int getPre() { return pre; };
        inline double getGmax() { return gmax; };
        inline double getErev() { return erev; };
        inline double getPSG() { return gout; };

        double getRise(int, int);
        double getFall(int, int);
        void setRise(double);
        void setFall(double);
        
        
        void execute(int);
        
        
        
    private:
    
        double dt;
        int pre;
        int post;
        double gmax; 
        double erev;
    
        double psgrise;
        double psgfall;
        
        
    
        PSG *psg;
        double gout; //This is the synaptic output conductance.
};



#endif
