
#ifndef NETWORK_H
#define NETWORK_H

#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include "SuperCell.h"
#include "Parameter.h"
#include "RealTimeLogger.h"
#include "InfoLogger.h"
#include "Synapse.h"

#include "RunParams.h"

using namespace std;

extern double params_dt;
extern double params_tend;
extern int params_downsample;
extern int params_print;
extern int params_saving;
extern string params_path;
extern string params_comment;

class Network {

    public:

        Network(void);
        virtual ~Network();

        void execute();
        void LoadNet(string);
        void WriteDatFile();
        void setInitCond(int, double);
        void setRecNum(int);
        void setCellNum(int);
        void runNegativeTime(double);
        void setPrint(int);
        int getNumberofCells();
        double getCellVm(int);
        void setCellVm(int, double);
        double getRealCellCurrent();
        int getRealIndex();


    private:

        vector <int> cells;
        vector <double> offsets;

        // old syns
        vector < vector <double> > synapses;
        vector < Synapse *> newsyns;

        vector <Parameter *> params;
        vector <SuperCell *> SuperCellVector;

        int readNet(string);
        void dispNetinfo();
        void DestroyNet();
        void AdjustParams();
        void BuildNet();



        string trimmed(string const&);
        int SplitString(const string&, const string&, vector<string>&, bool=false);
        void Tokenize(const string& str, vector<string>& tokens, const string& delimiters = " ");

        void print_error(int);
        vector<int> codes;

        vector<string> netfile;
        string netfn;
        int print;

        int rate;
        double dt;

        double tcnt;
        int cellnum;
        int realind;
        double realcur;
        string prefix, comment;

        // DataLogger
        RealTimeLogger *data;
        InfoLogger *info;;
};

#endif
