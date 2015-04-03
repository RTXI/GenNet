#!/usr/bin/python

import random
import math

numcells = 200
cnt = 0

def writesyn(pre, post, gmax, syn):
    if (syn == 0): esyn = '-65'
    if (syn == 1): esyn = '0'
    if (syn == 2):
        rsyn = random.randint(0,1)
        if (rsyn): esyn = '-90'
        else: esyn = '-10'
        
    f.write('>' + str(pre) + ',' + str(post) + ',' + str(gmax) + ',' + str(esyn) + '\n')
    

def randn(m, s, n):
    # generate a normally distributed random number with mean=0 and std=1
     for r in range(n):
         a.append(random.normalvariate(m,s))
     return a


# generate random applied currents
a = []
a = randn(2,0.5,numcells)

# open output file
f = open('nets/sm.net','w')

# generate cells
f.write('# Cells\n');
for r in a:
    f.write('@' + '4,' + str(r) + '\n')
    #f.write('@' + '5,0.2\n')

# other cells
f.write('@' + '1,.08\n')
f.write('@' + '1,.08\n')
f.write('@' + '2,8\n')
#f.write('@' + '0,0\n')

# generate synapses 
f.write('\n\n# Synapses\n')

# make synapses between all E-I and E-O pairs
geo = 1.2
gei = 0.03
goe = 0.8
gie = 2.0
for i in range(len(a)):
    f.write('# Syns for E cell' + str(i) + '\n');
    writesyn(i,len(a)+0,gei/len(a),1)
    writesyn(i,len(a)+1,gei/len(a),1)
    writesyn(i,len(a)+2,geo/len(a),1)
    writesyn(len(a)+0,i,gie,0)
    writesyn(len(a)+1,i,gie,0)
    writesyn(len(a)+2,i,goe,0)
    f.write('\n');

gio = 0.01;
goi = 0.1;
gii = 0.05;

f.write('# Syns for the I/O cells\n');
writesyn(len(a)+0,len(a)+1,gii,0)
writesyn(len(a)+0,len(a)+2,gio,0)
writesyn(len(a)+1,len(a)+0,gii,0)
writesyn(len(a)+1,len(a)+2,gio,0)
writesyn(len(a)+2,len(a)+0,goi,0)
writesyn(len(a)+2,len(a)+1,goi,0)
