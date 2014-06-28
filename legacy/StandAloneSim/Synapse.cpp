/**
* Synapse
*/

#include "Synapse.h"
#include "SuperCell.h"

Synapse::Synapse(double dd, int pr, int po, double gx, double er, int pretype, int posttype) {
    dt = dd;
    pre = pr;
    post = po;
    gmax = gx;
    erev = er;
    
    // initialize the PSG
    // set rise and fall times based on cell *types*
    psgrise = getRise(pretype, posttype);
    psgfall = getFall(pretype, posttype);
    
    psg = new PSG(psgrise, psgfall, dt);
}

Synapse::~Synapse(void) {}

void Synapse::execute(int state) {
    
    // let the PSG know if cell is spiking
    psg->setState(state);
    
    // conductance of the syn
    gout = psg->update(dt);
}

/**
 * These two functions determine what parameters
 * to use for synaptic kinetics depending on pre and post synaptic cells
 * see documentation for references for these numbers
 */
double Synapse::getRise(int pr, int po) {
    
    // cout << "Rise: Pre: " << pr << " -- Post: " << po << endl;
    
    // different models of the same cell have the same kinetics
    if (pr == 6) pr = SuperCell::ICELL;
    if (pr == 7) pr = SuperCell::OCELL;
    
    
    if (pr == SuperCell::ECELL && po == SuperCell::OCELL) {
        return 1;
    } else if (pr == SuperCell::ECELL && po == SuperCell::ICELL) {
        return 0.7;
    } else if (pr == SuperCell::OCELL && po == SuperCell::ECELL) {
        return 8;
    } else if (pr == SuperCell::OCELL && po == SuperCell::ICELL) {
        return 1;
    } else if (pr == SuperCell::ICELL && po == SuperCell::OCELL) {
        return 1;
    } else if (pr == SuperCell::ICELL && po == SuperCell::ICELL) {
        return 1;
    } else if (pr == SuperCell::ICELL && po == SuperCell::ECELL) {
        return 0.7;
    } else {
        //cout << "warning: default rise time used for Syn from " << pr << " to " << po << endl;
        return 0.7;
    }
}

double Synapse::getFall(int pr, int po) {
    
    // cout << "Fall: Pre: " << pr << " -- Post: " << po << endl;
    
    // different models of the same cell have the same kinetics
    if (pr == 6) pr = SuperCell::ICELL;
    if (pr == 7) pr = SuperCell::OCELL;
    
    
    if (pr == SuperCell::ECELL && po == SuperCell::OCELL) {
        return 8;
    } else if (pr == SuperCell::ECELL && po == SuperCell::ICELL) {
        return 3;
    } else if (pr == SuperCell::OCELL && po == SuperCell::ECELL) {
        return 12;
    } else if (pr == SuperCell::OCELL && po == SuperCell::ICELL) {
        return 20;
    } else if (pr == SuperCell::ICELL && po == SuperCell::OCELL) {
        return 9;
    } else if (pr == SuperCell::ICELL && po == SuperCell::ICELL) {
        return 8;
    } else if (pr == SuperCell::ICELL && po == SuperCell::ECELL) {
        return 6;
    } else {
        //cout << "warning: default fall time used for Syn from " << pr << " to " << po << endl;
        return 5.6;
    }
}

void Synapse::setRise(double r) {
    psgrise = r;
    psg->setRise(psgrise);
}

void Synapse::setFall(double f) {
    psgfall = f;
    psg->setFall(psgfall);
}

/* 
 * inlined now
int Synapse::getPre() {
    return pre;
}

int Synapse::getPost() {
    return post;
}

double Synapse::getGmax() {
    return gmax;
}

double Synapse::getErev() {
    return erev;
}

double Synapse::getPSG() {
    return gout;
}
*/



