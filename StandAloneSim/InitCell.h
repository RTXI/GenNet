
#ifndef INITCELL_H
#define INITCELL_H

#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include "SuperCell.h"


using namespace std;

class InitCell {

    public:

        InitCell(double);
        virtual ~InitCell();

        void setType(int);
        void setGl(double);
        void setDi(double);
        void setDe(double);
        void setGavgi(double);
        void setGavge(double);
        void setTaui(double);
        void setTaue(double);
        void execute(double);
        double getCellVm();
        void setCellVm(double);
        void BuildNet();

    private:


        SuperCell * SuperCellptr;

        double rate;
        int celltype;
};

#endif
