#ifndef INFOLOGGER_H
#define INFOLOGGER_H


#include <vector>
#include <string>
#include <iostream>
#include <fstream>


using namespace std;


class InfoLogger 
{ 
public:
    InfoLogger();
    virtual ~InfoLogger(void);

    virtual void insertdata(string);
    virtual void writebuffer(string, string, int);
    virtual void resetbuffer();
    virtual void setRecNum(int);
    virtual void setPrint(int);
    virtual void newcell(int);
    bool fileExists(string);

    void dumpData();

private:

    void create_fns(string);
    string create_path(void);
	
    vector< string > buffer; 

    int cellnum;
    int recnum;
    int print;

    string datafn;
    string logfn;
    string timeofday; 

    string path;
};

#endif 
