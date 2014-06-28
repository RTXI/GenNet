#include <stdlib.h>
#include "InitCell.h"
#include "ECell.h"
#include "OCell.h"
#include "ICell.h"
#include "IZTonic.h"
#include "IZClass1.h"
#include "WangBuzsaki.h"
#include "GhostCell.h"
#include "SuperCell.h"
#include "OLM.h"
#include "MSPyCell.h"
#include "FSCell.h"
#include "LIFe.h"
#include "LIFi.h"
#include "aeLIF.h"

using namespace std;


InitCell::InitCell(double r) {
     rate = r;
}



InitCell::~InitCell(void) {
}



void InitCell::setType(int t) {
    celltype = t;
}



void InitCell::setGl(double g) {
    SuperCellptr->setGl(g);
}



void InitCell::setDi(double d) {
    SuperCellptr->setDi(d);
}



void InitCell::setDe(double d) {
    SuperCellptr->setDe(d);
}



void InitCell::setTaue(double t) {
    SuperCellptr->setTaue(t);
}



void InitCell::setTaui(double t) {
    SuperCellptr->setTaui(t);
}



void InitCell::setGavge(double g) {
    SuperCellptr->setGavge(g);
}



void InitCell::setGavgi(double g) {
    SuperCellptr->setGavgi(g);
}



void InitCell::BuildNet(void) {
        switch (celltype) {
            case -1: 
               break;
            case 0: 
               SuperCellptr = new ECell(1000.0/rate);
               break;
            case 1:
                SuperCellptr = new ICell(1000.0/rate);
                break;
            case 2:
                SuperCellptr = new OCell(1000.0/rate);
                break;
            case 3:
                SuperCellptr = new GhostCell(1000.0/rate);
                break;
            case 4:
                SuperCellptr = new IZTonic(1000.0/rate);
                break;
            case 5:
                SuperCellptr = new IZClass1(1000.0/rate);
                break;
            case 6:
                SuperCellptr = new WangBuzsaki(1000.0/rate);
                break;
            case 7:
                SuperCellptr = new OLM(1000.0/rate);
                break;
            case 8:
                SuperCellptr = new MSPyCell(1000.0/rate);
                break;
            case 9:
                SuperCellptr = new FSCell(1000.0/rate);
                break;
            case 10:
                SuperCellptr = new LIFe(1000.0/rate);
                break;
            case 11:
                SuperCellptr = new LIFi(1000.0/rate);
                break;
            case 12:
                SuperCellptr = new aeLIF(1000.0/rate);
                break;
            case 13:
                SuperCellptr = new aeLIF(1000.0/rate);
                break;
            default:
                cerr << "Error: Unknown Cell number: " << celltype << endl;
                break;
    } 
}



void InitCell::execute(double Iin) {
    SuperCellptr->execute(Iin);
}



double InitCell::getCellVm() {
    return SuperCellptr->getVoltage()*1e-3;
}



void InitCell::setCellVm(double v) {
    SuperCellptr->setVoltage(v*1e3);
}





