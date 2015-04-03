/**
 * StandAloneSim.h = Header file for the StandAloneSim. 
 */

#ifndef STANDALONESIM_H
#define STANDALONESIM_H


//#include <qstringlist.h>
//#include <qstring.h>
#include <string>
#include "Network.h"


using namespace std;

class StandAloneSim {
    public:
    
        StandAloneSim(void);
        virtual ~StandAloneSim(void);
        
        void execute(void);
        void helpRecNum(int);
        void updateIh(double);
        void setInitCond(int, double);
        
        void LoadNet(string);
        void WriteDatFile();
        void setRecNum(int);
        void runNegativeTime(double);
        void setPrint(int);

    private:
     
        int rate;
        double dt;
        
        string netfn;
        Network *n;        
};


#endif
