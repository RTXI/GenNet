/**
 * Logs information about each run including the net file and a comment.
 */
 
 
#include "InfoLogger.h"
#include "RunParams.h"
#include <time.h>
#include <string>
#include <sys/stat.h>

InfoLogger::InfoLogger() 
{
   cellnum = 1;
   recnum = 1;
   path = params_path;
   print = params_print;
   
}


InfoLogger::~InfoLogger(void) {
}


void InfoLogger::newcell(int num)
{
  if (cellnum != num) {
    cellnum = num;
    recnum = 1;
  }
}


void InfoLogger::setRecNum(int rn) {
    recnum = rn;
}


void InfoLogger::setPrint(int p) {
    print = p;
}


void InfoLogger::insertdata(string newdata) {
    if (params_saving) {

        buffer.push_back(newdata);
    }
}


void InfoLogger::resetbuffer()
{
    buffer.clear();
}



bool InfoLogger::fileExists(string fn) {
        struct stat stf;
        int is;

        is = stat(fn.c_str(), &stf);
        if (is==0) {
                return true;
        } else {
                return false;
        }
}



void InfoLogger::writebuffer(string prefix, string comment, int nc)
{
    if (params_saving == 0) {
        return;
    }
    create_fns(prefix);

   while (fileExists(path+datafn)) {

         if (print) cout << "Specified info file " << datafn << " already exists." << endl;

         int ind_ = datafn.find_last_of("_");
         datafn = datafn.substr(0, ind_+1);
         char endstring[20];
         recnum++;
         sprintf(endstring, "%c%d.info", ((int)cellnum)+64, (int)recnum);
         datafn.append(endstring);
    }

    // open the info file as a text file
    ofstream info_file ((path + datafn).c_str(), ios::out);

    if (info_file.is_open()) {
        
        // write number of columns to file
        info_file << "numcols:" << nc << endl << endl;
        
        // write comment string to file first
        info_file << comment << endl << endl;

        // output net file
        for (int i = 0; i < (int)buffer.size(); i++) {
            // output a data point
            //data_file.write(reinterpret_cast<char*>(&buffer[i][j]),sizeof(double));
            //cout << "i: " << i << " j: " << j << endl;
            // we are only writing string so just use C++ file I/O
            info_file << buffer[i] << endl;
        }
        recnum++;
    } else {
        if (print) cout << "Unable to open file " << datafn << endl;
        return;
    }

    info_file.close();
    if (print) cout << "Info file " << datafn << " written successfully." << endl;
}


/**
 * Test function to output the vector
 */
void InfoLogger::dumpData() {
    
    for (int i = 0; i < (int)buffer.size(); i++) {
        cout << "element " << i << ": " << buffer[i] << endl;
    }
}

    
void InfoLogger::create_fns(string prefix)
{
    char tstring[80];
    time_t sec;
    time (&sec);
    strftime(tstring, 80,"%b_%d_%y", localtime(&sec));

    // convert doubles to ints for printing, change cellnum to ANSI char
    char trial[80];
    sprintf(trial, "_%c%d.info", ((int)cellnum)+64, (int)recnum);
    
    char t_o_d[80];
    strftime(t_o_d, 80, "%T", localtime(&sec));
    timeofday = string(t_o_d);
    
    datafn = prefix + "_" + string(tstring) + string(trial);
    logfn = string(tstring) + ".log";
}

