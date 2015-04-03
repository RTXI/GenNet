#include "RealTimeLogger.cpp"
#include <math.h>
#include <stdlib.h>

int main () {

    int cols = 20;
    int rows = 500;

    RealTimeLogger *rtl = new RealTimeLogger(cols * rows, cols);
    rtl->setPrint(1);


    for (int i = 0; i < cols*rows; i++) {
        rtl->insertdata((double)rand() / RAND_MAX);
    }

    rtl->dumpData();

    rtl->writebuffer("TestLogger", "???");
    return 0;
}
