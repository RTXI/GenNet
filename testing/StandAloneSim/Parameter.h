/**
 * A parameter to change in the simulation
 */

#ifndef PARAMETER_H
#define PARAMETER_H


#include <iostream>
#include <fstream>
#include <string>
#include <vector>


using namespace std;

class Parameter {
    public:
    
        Parameter(int, string, double, int);
        virtual ~Parameter(void);

        void out();
        int getInd();
        string getKey();
        double getVal();
        int getType();
        
    private:

        int ind;     // index of syn or cell in its list
        double val;  // new value to change to
        string key;  // name of parameter to change
        int type;    // synaptic or cell parameter (0 or 1)
};

#endif
