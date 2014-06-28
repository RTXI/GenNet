#ifndef REALCELL_H
#define REALCELL_H

#include "SuperCell.h"

using namespace std;


class PatchedCell : public SuperCell {

    public:

        PatchedCell(double dd);
        virtual ~PatchedCell(void);

        void out(double);


    private:

        // solver- the main one is in SuperCell
        void derivs(void);        

        static const double psgfall;
        static const double psgrise;


};

#endif 
