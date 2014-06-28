/**
 * Stand alone data recorder  
 */
 
 
#include "RealTimeLogger.h"
#include "RunParams.h"
#include <time.h>
#include <sys/stat.h>

RealTimeLogger::RealTimeLogger(int bs, int cols) 
{
   cellnum=1;
   recnum=1;
   path = params_path;
   print = params_print;
   bufsize = bs;
   
   // number of columns in the data set
   numcols = cols;
   
   // do not downsample by default
   downsample = 1;
   bufpos = 0;

   allocateBuffer(bufsize);
}


RealTimeLogger::~RealTimeLogger(void)
{ 
   if (params_saving) {
         delete(buffer);
    }
}


void RealTimeLogger::allocateBuffer(int bufsize) {
    if (params_saving) {
        buffer = new double [bufsize];
        cerr << "Buffer created with " << bufsize << " entries" << endl;
    } else {
        cerr << "Not saving data, no buffer created!" << endl;
    }
}


void RealTimeLogger::newcell(int num)
{
  if (cellnum != num) {
    cellnum = num;
    recnum = 1;
  }
}


void RealTimeLogger::setRecNum(int rn) {
    recnum=rn;
}


void RealTimeLogger::setPrint(int p) {
    print = p;
}


void RealTimeLogger::insertdata(double newdata) 
{
    if (params_saving == 0) {
        return;
    }

    if (bufpos < bufsize) {
        buffer[bufpos] = newdata;
    } else {
        cerr << "WARNING: bufpos = " << bufpos << " when bufsize = " << bufsize << ".  Not inserting.  " << endl;
    }
    bufpos++;
}


void RealTimeLogger::resetbuffer()
{
    bufpos = 0;
}


int RealTimeLogger::getNumCols() {
    return numcols;
}


void RealTimeLogger::setDSRate(int ds) {
    downsample = ds;
}


bool RealTimeLogger::fileExists(string fn) {
	struct stat stf;
	int is;

	is = stat(fn.c_str(), &stf);
	if (is==0) {
		return true;
	} else {
		return false;
	}
}




/*string RealTimeLogger::getTimeStamp() {
	char tstring[80];
	time_t sec;
	time (&sec);
	strftime(tstring, 80, "%H%M%S", localtime(&sec));
	return string(tstring);
}*/



void RealTimeLogger::writebuffer(string prefix, string fileinfo)
{
    if (params_saving == 0) {
        return;
    }
    create_fns(prefix);

    while (fileExists(path+datafn)) {
	 if (print) cout << "Specified data file " << datafn << " already exists." << endl;
         int ind_ = datafn.find_last_of("_");
         datafn = datafn.substr(0, ind_+1);
         char endstring[20];
         recnum++;
	 sprintf(endstring, "%c%d.dat", ((int)cellnum)+64, (int)recnum);
         datafn.append(endstring);
    }

    // open the file as binary
    ofstream data_file ((path + datafn).c_str(), ios::binary | ios::out);
    //ofstream log_file  (logfn.c_str(), ios::out);


    if (data_file.is_open()) {


        for (int i = 0; i <= bufsize-numcols; i+=downsample*numcols) {
            for (int j=0; j < numcols; j++) {
                if ((i+j) < bufsize) {
                    data_file.write(reinterpret_cast<char*>(&buffer[i+j]),sizeof(double));
                } else {
                    cerr << "Buffer index error:  Buffer index out of range" << endl;
                }
            }
        }
    } else {
        if (print) cout << "Unable to open file " << (path + datafn).c_str() << endl;
        return;
    }

    /*    if (data_file.is_open()) {

    // write buffer to file
    for (int i = 0; i < bufsize; i+=downsample) {
    data_file.write(reinterpret_cast<char*>(&buffer[i]),sizeof(double));
    }
    } else {
        cout << "Unable to open file " << (path + datafn).c_str() << endl;
    }*/

    data_file.close();
    if (print) cout << "Data file " << datafn << " written successfully." << endl;
    update_log(fileinfo);
}


void RealTimeLogger::update_log(string fileinfo)
{
    if (params_saving == 0) {
        return;
    }


    ofstream log_file ((path + logfn).c_str(), ios::out | ios::app);
    if (log_file.is_open()) {
        log_file << timeofday<< " " << datafn << ": " << fileinfo << endl;
    }
    log_file.close();
    if (print) cout << "Log file " << logfn << " written successfully." << endl;

}


/**
 * Test function to output the vector
 */
void RealTimeLogger::dumpData() {

    for (int j = 0; j < bufsize; j++) {
        printf("element %d: %f\n", j, buffer[j]);
    }
}


void RealTimeLogger::create_fns(string prefix)
{
    char tstring[80];
    time_t sec;
    time (&sec);
    strftime(tstring, 80,"%b_%d_%y", localtime(&sec));

    // convert doubles to ints for printing, change cellnum to ANSI char
    char trial[80];
    sprintf(trial, "_%c%d.dat", ((int)cellnum)+64, (int)recnum);

    char t_o_d[80];
    strftime(t_o_d, 80, "%T", localtime(&sec));
    timeofday = string(t_o_d);

    datafn = prefix + "_" + string(tstring) + string(trial);
    logfn = string(tstring) + ".log";
}

