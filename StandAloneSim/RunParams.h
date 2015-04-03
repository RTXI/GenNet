
#ifndef RUNPARAMS_H
#define RUNPARAMS_H

#include <string>

using namespace std;

// period
extern double params_dt;

// how much time to run (ms)
extern double params_tend;

// factor by which to downsample data acquistion
 extern int params_downsample;

// print output?
 extern int params_print;

// save data?
 extern int params_saving;

// path to save data
 extern string params_path;

// Comment to include in info files
extern string params_comment;

#endif
