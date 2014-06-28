#include <stdlib.h>
#include "Network.h"
#include "ECell.h"
#include "OCell.h"
#include "ICell.h"
#include "IZTonic.h"
#include "IZClass1.h"
#include "WangBuzsaki.h"
#include "GhostCell.h"
#include "Synapse.h"
#include "SuperCell.h"
#include "OLM.h"
#include "MSPyCell.h"
#include "FSCell.h"
#include "LIFe.h"
#include "LIFi.h"
#include "aeLIF.h"
#include "RunParams.h"
#include "PatchedCell.h"
#include <math.h>

using namespace std;

extern double params_dt;
extern double params_tend;
extern int params_downsample;
extern int params_print;
extern int params_saving;
extern string params_path;
extern string params_comment;


/**
 * This class encapsulates the core functionality of GenNet. 
 */

Network::Network(void) {

     tcnt = 0.0;
     realind = -666;
     realcur = 0;
     
     dt = params_dt;
     cellnum = 1;
     prefix = "GenNet";

     netfn = "";
     print = params_print;

}

Network::~Network(void) {
    delete(data); 
    for (unsigned int i = 0; i< newsyns.size(); i++) {
        delete(newsyns[i]);
    }
    for (unsigned int i = 0; i<params.size(); i++) {
        delete(params[i]);
    }
}

void Network::LoadNet(string filename) {

    info = new InfoLogger();
    info->newcell(cellnum);

    netfn = filename;
    readNet(filename);
    dispNetinfo();
    BuildNet();
    AdjustParams();

    int cols = cells.size() + 1;  // number of cells + one column for tcnt
    data = new RealTimeLogger((int)round((params_tend / dt * cols)), cols);

    data->newcell(cellnum);
    data->setDSRate(params_downsample);
    data->setPrint(params_print);

}


void Network::DestroyNet(void){

    SuperCellVector.clear();
    cells.clear();
    offsets.clear();
    synapses.clear();
    params.clear();
}


/** 
 * Change a user specified parameter
 */
void Network::AdjustParams() {

    for (unsigned int i = 0; i < params.size(); i++) {

        int ind = params[i]->getInd();
        string key = params[i]->getKey();
        double val = params[i]->getVal();
        int type = params[i]->getType();

        //cout << "Changing: " << ind << "," << key << "," << val << "," << type << endl;

        switch(type) {
            // cells
            case 0:
                // right now we can only do this for the OCell and for gh
                if (key.compare("gh") == 0 && SuperCellVector[ind]->getType() == SuperCell::OCELL) {
                    // adjust the parameter for the OCell
                    ((OCell *)(SuperCellVector[ind]))->setGh(val);
                    //                cout << "Changed Cell " << ind << " to have gh = " << ((OCell *)(SuperCellVector[ind]))->getGh() << endl;
                } else if (key.compare("negT") == 0) {
                    (SuperCellVector[ind])->setnegT(val);
                    //              cout << "Changed Cell " << ind << " to run in negative time for " << (SuperCellVector[ind])->getnegT() << " Seconds" << endl;
                } else if (key.compare("Di") == 0) {
                    (SuperCellVector[ind])->setDi(val);
                    //    cout << "Changed Cell " << ind << " to have inhibitory noise equal to  " << val << endl;

                } else if (key.compare("De") == 0) {
                    (SuperCellVector[ind])->setDe(val);
                    //                cout << "Changed Cell " << ind << " to have excitatory noise equal to  " << val << endl;
                } else if (key.compare("taue") == 0) {
                    (SuperCellVector[ind])->setTaue(val);
                    //    cout << "Changed Cell " << ind << " to have excitatory time constant equal to  " << val << endl;
                } else if (key.compare("taui") == 0) {
                    (SuperCellVector[ind])->setTaui(val);
                    //  cout << "Changed Cell " << ind << " to have inhibitory time constant equal to  " << val << endl;
                } else if (key.compare("Gl") == 0) {
                    (SuperCellVector[ind])->setGl(val);

                } else if (key.compare("gavgi") == 0) {
                    (SuperCellVector[ind])->setGavgi(val);

                } else if (key.compare("gavge") == 0) {
                    (SuperCellVector[ind])->setGavge(val);

                } else if (key.compare("minint") == 0) {
                    (SuperCellVector[ind])->detect->setMinint(val);

                } else {
                    cerr << "Warning: unknown paramter change:" << endl;
                    // cout << "\tCell: " << ind << " key: " << key << " val: " << val << endl;
                }
                break;

                // synapses    
            case 1:

                if (key.compare("psgrise") == 0) {
                    newsyns[ind]->setRise(val);
                } else if (key.compare("psgfall") == 0) {
                    newsyns[ind]->setFall(val);
                } else {
                    cerr << "Warning: unknown paramter change:" << endl;
                    cerr << "\tCell: " << ind << " key: " << key << " val: " << val << endl;
            }
            break;
        default:
            break;
        }
        
    //    cout << "Parameter Change: " << (type ? "Synapse " : "Cell ") << ind << " - " << key << " = " << val << endl; 
    }
}

/**
 * Run a specified cell a bit before we do the sim
 * This can be helpful to allow variables to get to steady states
 */
void Network::runNegativeTime(double dt) {

    // cout << "running cell " << ind << " for " << ts << "timesprest"<< endl;
    for (unsigned int i = 0; i < SuperCellVector.size(); i++) {
        if (SuperCellVector[i]->getnegT()>0) {
            for (double t = 0; t < SuperCellVector[i]->getnegT(); t+=dt) {
                SuperCellVector[i]->execute(offsets[i]);
              //  cout << SuperCellVector[i]->Iapp << endl;
            }
        }
    }
}

void Network::setRecNum(int rn) {
    data->setRecNum(rn);
    info->setRecNum(rn);
}


void Network::setCellNum(int cn) {
    cellnum = cn;
}



void Network::setInitCond(int ind, double val) {
    SuperCellVector[ind]->setVoltage(val);
}

void Network::BuildNet(void) {
     for(unsigned int i = 0; i < cells.size(); i++ ) {     
        switch (cells[i]) {
            case -1: 
               SuperCellVector.push_back(new PatchedCell(dt));
               realind = i;
               break;
            case 0: 
               SuperCellVector.push_back(new ECell(dt));
               break;
            case 1:
                SuperCellVector.push_back(new ICell(dt));
                break;
            case 2:
                SuperCellVector.push_back(new OCell(dt));
                break;
            case 3:
                SuperCellVector.push_back(new GhostCell(dt));
                break;
            case 4:
                SuperCellVector.push_back(new IZTonic(dt));
                break;
            case 5:
                SuperCellVector.push_back(new IZClass1(dt));
                break;
            case 6:
                SuperCellVector.push_back(new WangBuzsaki(dt));
                break;
            case 7:
                SuperCellVector.push_back(new OLM(dt));
                break;
            case 8:
                SuperCellVector.push_back(new MSPyCell(dt));
                break;
            case 9:
                SuperCellVector.push_back(new FSCell(dt));
                break;
            case 10:
                SuperCellVector.push_back(new LIFe(dt));
                break;
            case 11:
                SuperCellVector.push_back(new LIFi(dt));
                break;
            case 12:
                SuperCellVector.push_back(new aeLIF(dt));
                break;
            case 13:
                SuperCellVector.push_back(new aeLIF(dt));
                break;
            default:
                cerr << "Error: Unknown Cell number: " << cells[i] << endl;
                break;
        }
    } 
}

void Network::WriteDatFile() {

    // write info file but do not delete the buffer 
    // so the netfile isn't deleted between acquisitions
    info->writebuffer(prefix, params_comment, data->getNumCols());

    data->writebuffer(prefix, params_comment);
    data->resetbuffer();
}


void Network::print_error(int code) {
}

// parse input netfile
int Network::readNet(string file) {
    
    string s;
    ifstream net_file(file.c_str(), ios::in);
    vector<string> syn_list;
    string syn;
    vector<string> cell_list;
    string c;
    string line;
        
    vector< double > one_syn;
    
    cells.clear();
    synapses.clear();
    newsyns.clear();
    offsets.clear();
    params.clear();

    if (net_file.is_open()) {
        while (!net_file.eof()) {
            getline (net_file, s);
            line = trimmed(s);

            // log the netfile so we have it for later
            netfile.push_back(line);
            info->insertdata(line);
            
            // remove comments and ignore empty lines
            if (line[0]=='#' || line.length() == 0)
                continue;

            // list of cells
            if (line[0]=='@') {
               
                // remove removes the first character which is the @ sign. 
                line.erase(0,1);
                //SplitString(line, ",", cell_list);
                Tokenize(line, cell_list, ",");

                c=cell_list[0];
                c=trimmed(c);
                cells.push_back(atoi(c.c_str()));
                
                c=cell_list[1];
                c=trimmed(c);
                //cout << cell_list[0] << cell_list[1] << cell_list.size() << endl;
                offsets.push_back(atof(c.c_str()));                

                // have an extra parameter to change
                if (cell_list.size() > 2) {
                    
                    vector<string> param_list;
                    
                    // for each additional parameter listed
                    for(unsigned int i = 2; i < cell_list.size(); i++) {
                        
                    
                        //SplitString(cell_list[i], "=", param_list);
                        Tokenize(cell_list[i], param_list, "=");

                        int cell_ind = -1;
                        string key = "xx";
                        double val = -99.0;
                        
                        // trim stuff later?
                        if (param_list.size() != 2) {
                            cerr << "Error: couldn't find key and value for param change (gh=0.0), syntax error? Skipping... " << endl;
                            cerr << "\tSize of param_list: " <<  param_list.size()  << endl;
                            cerr << "\tCell list[2]: >" << cell_list[2] << "<" << endl;
                            continue;
                        } else {
                            // index of the most recently created cell
                            cell_ind = cells.size()-1;
                            key = param_list[0];
                            val = atof(param_list[1].c_str());
                        }

                        // save this parameter change for after we have created
                        // the network
                        params.push_back(new Parameter(cell_ind, key, val, 0));
                        param_list.clear();
                    }
                }
                
                
                cell_list.clear();
            }

            // new way to do syns
            if (line[0] == '>') {
                line.erase(0,1);
                //SplitString(line, ",", syn_list);
                Tokenize(line, syn_list, ",");
                
                int pr, po = 0;
                double gm, er = 0;
                
                // check some basic errors
                if (syn_list.size() >= 4) {
                    // turn everything into a number
                    pr = (int)(atof(trimmed(syn_list[0]).c_str()));
                    po = (int)(atof(trimmed(syn_list[1]).c_str()));
                    gm = atof(trimmed(syn_list[2]).c_str());
                    er = atof(trimmed(syn_list[3]).c_str());
                    
                    // can the unsigned part be a problem when we use -1 for 'real cells w/ RTXI? I don't think so
                    if ((unsigned)pr < cells.size() && (unsigned)po < cells.size()) {
                        
                        // create a new synapse object given the parameters
                        newsyns.push_back(new Synapse(dt, pr, po, gm, er, cells[pr], cells[po]));
                        
                    } else {
                        cerr << "ERROR: Synapse #" << newsyns.size() << " is out of range and is being skipped..." << endl;
                    }
                }  else {
                    cerr << "ERROR: Synapse #" << newsyns.size() << " is invalid and is being skipped..." << endl;
                }
                
                // parameter changes
                if (syn_list.size() > 4) {
                    
                    vector<string> param_list;
                    
                    // for each additional parameter listed
                    for(unsigned int i = 4; i < syn_list.size(); i++) {
                    
                        //SplitString(trimmed(syn_list[i]), "=", param_list);
                        Tokenize(trimmed(syn_list[i]), param_list, "=");

                        int syn_ind = -1;
                        string key = "xx";
                        double val = -99.0;
                        
                        // trim stuff later?
                        if (param_list.size() != 2) {
                            cerr << "Error: couldn't find key and value for param change (psgrise=0.0), syntax error? Skipping... " << endl;
                            cerr << "\tSize of param_list: " <<  param_list.size()  << endl;
                            cerr << "\tSyn list[i]: >" << syn_list[i] << "<" << endl;
                            continue;
                        } else {
                            // index of the most recently created cell
                            syn_ind = newsyns.size()-1;
                            key = trimmed(param_list[0]);
                            val = atof(trimmed(param_list[1]).c_str());
                        }

                        // save this parameter change for later
                        params.push_back(new Parameter(syn_ind, key, val, 1));
                        param_list.clear();
                    }
                }
                syn_list.clear();
            }
        }
    } else {
        // file not open
        return(1);
    }
    
    //success
    return (0);
}


string Network::trimmed(string const& str)
{
    char *sepSet = (char *)" ";
    string::size_type const first = str.find_first_not_of(sepSet);
    return ( first==string::npos )
    ? string()
    : str.substr(first, str.find_last_not_of(sepSet)-first+1);
}

void Network::Tokenize(const string& str,
                      vector<string>& tokens,
                      const string& delimiters)
{
    // Skip delimiters at beginning.
    string::size_type lastPos = str.find_first_not_of(delimiters, 0);
    // Find first "non-delimiter".
    string::size_type pos     = str.find_first_of(delimiters, lastPos);

    while (string::npos != pos || string::npos != lastPos)
    {
        // Found a token, add it to the vector.
        tokens.push_back(str.substr(lastPos, pos - lastPos));
        // Skip delimiters.  Note the "not_of"
        lastPos = str.find_first_not_of(delimiters, pos);
        // Find next "non-delimiter"
        pos = str.find_first_of(delimiters, lastPos);
    }
}

           
int Network::SplitString(const string& input, const string& delimiter, vector<string>& results, bool includeEmpties)
{
    int iPos = 0;
    int newPos = -1;
    int sizeS2 = (int)delimiter.size();
    int isize = (int)input.size();

    if ((isize == 0) || (sizeS2 == 0)) {
        return 0;
    }

    vector<int> positions;
    newPos = input.find (delimiter, 0);

    if (newPos < 0) { 
        return 0; 
    }

    int numFound = 0;

    while(newPos >= iPos) {
        numFound++;
        positions.push_back(newPos);
        iPos = newPos;
        newPos = input.find (delimiter, iPos+sizeS2);
    }

    if(numFound == 0) {
        return 0;
    }

    for(unsigned int i = 0; i <= (unsigned int)positions.size(); ++i) {
        string s("");
        if (i == 0) { 
            s = input.substr(i, positions[i]); 
        }
        
        int offset = positions[i-1] + sizeS2;
        if (offset < isize) {
            
            if (i == positions.size()) {
                s = input.substr(offset);
            }
            else if(i > 0) {
                s = input.substr( positions[i-1] + sizeS2, 
                      positions[i] - positions[i-1] - sizeS2 );
            }
        }
        if (includeEmpties || ( s.size() > 0 )) {
            results.push_back(s);
        }
    }
    return numFound;
}

// Evolve the network for one time stamp
void Network::execute(void) {
    vector <double> Isyns(cells.size(),0);
    vector <double> tempsyn;
    vector <double> tempdata;
    int pre;
    int post;
    double Gm;
    double E; 
    double S;
    double postV = 0;
    
    // evolve synapses
    for(unsigned int i = 0; i < newsyns.size(); i++) {
        
        pre = newsyns[i]->getPre();    
        post = newsyns[i]->getPost();
        Gm = newsyns[i]->getGmax();
        E = newsyns[i]->getErev();
        
        S = newsyns[i]->getPSG();
        postV = SuperCellVector[post]->getVoltage();

        //cout << "G: " << Gm << " S: " << S << " postV: " << postV << endl;

        
        Isyns[post] += Gm * S * (E - postV);

        //cout << "I0: " << Isyns[0] << " I1: " << Isyns[1] << endl;
        
        int state = SuperCellVector[pre]->detect->getState();
        newsyns[i]->execute(state);
    }

    //Data logging
    if (params_saving) {
        data->insertdata(tcnt);
    }

    //evolve cells
    for(unsigned int i = 0; i < cells.size(); i++ ) {
        // run the individual cells
        
        SuperCellVector[i]->execute(offsets[i]+Isyns[i]);

        // save data, Convert to volts
        if (params_saving) {
            data->insertdata(SuperCellVector[i]->getVoltage()*1e-3);
        }
    }   

    // ???
    if (realind != -666) {
	    realcur = offsets[realind]+Isyns[realind];

   }     
    // store Voltage values
    tcnt += dt/1000.0;
}

void Network::dispNetinfo() {
	unsigned int i, j;

	if (print) {
		cout << endl << "\tCurrent Network Topology" << endl;
		cout <<         "\t------------------------" << endl;
		for (i = 0; i < cells.size(); ++i) {
			cout << "\tCell " << i << " is type " << cells[i] << " w/ offset: " << offsets[i] << endl;
		}
		cout << endl;


		// output header
		cout << "\t\t\tPr->Po\tGsyn\tErev" << endl;
		cout << "\t------------------------------------" << endl;
		for (j = 0; j < newsyns.size(); ++j) {
			cout << "\tSynapse #" << j << ":\t" << newsyns[j]->getPre() << " -> " << newsyns[j]->getPost() << "\t\t" << newsyns[j]->getGmax() << "\t" << newsyns[j]->getErev() << endl;
		}
		cout << endl;
	}
}

void Network::setPrint(int p) {
	print = p;
}

double Network::getCellVm(int ind) {

    // return the voltage of a cell
    // the parameter is the index (incase Network doesn't know where it is)
    return SuperCellVector[ind]->getVoltage()*1e-3;
}

int Network::getNumberofCells() {
    return cells.size();
}

void Network::setCellVm(int ind, double v) {
    SuperCellVector[ind]->setVoltage(v*1e3);
}

int Network::getRealIndex() {
    return realind;
}

double Network::getRealCellCurrent() {
    return realcur*1e-12;
}
