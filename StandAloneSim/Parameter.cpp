/**
 * Parameter to change in GenNet
 */

#include "Parameter.h"
#include <string>

Parameter::Parameter(int i, string k, double v, int t) {
    ind = i;
    key = k;
    val = v;
    type = t;
}

Parameter::~Parameter() {}

void Parameter::out() {
    cout << "Parameter for cell " << ind << " key: " << key << " val: " << val << endl;
}

int Parameter::getInd() {
    return ind;
}

string Parameter::getKey() {
    return key;
}

double Parameter::getVal() {
    return val;
}

int Parameter::getType() {
    return type;
}



