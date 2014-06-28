# This Makefile seems to work fine as far as I know
# 'backup' won't work on Cygwin until you install 'zip'

OBJECTS = SuperCell.o InfoLogger.o PSG.o SpikeDetect.o Network.o \
IZTonic.o ECell.o OCell.o ICell.o WangBuzsaki.o GhostCell.o OLM.o \
Parameter.o StandAloneSim.o Synapse.o IZClass1.o MSPyCell.o FSCell.o LIFe.o \
LIFi.o aeLIF.o RealTimeLogger.o RunParams.o PatchedCell.o

EXE = gn
CC = g++
CFLAGS = -ansi -Wall -O2
PROF = 
DATDIR = DATA

$(EXE): $(OBJECTS)
	$(CC) $(OBJECTS) $(PROF) -o $(EXE)

%.o: %.cpp %.h
	$(CC) $(CFLAGS) $(PROF) -o $@ -c $< 
    
clean:
	rm -f $(OBJECTS) $(EXE)

# backup all cpp, h, py, m, and pl files and this Makefile
backup:
	 find ./ -maxdepth 1 -name "*.cpp" -or -name "*.h" -or -name "*.m" -or -name "*.pl" -or -name "*.py" | zip gennet_backup -@ Makefile
