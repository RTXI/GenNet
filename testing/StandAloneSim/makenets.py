#!/usr/bin/python

import random
import math

numcells = 10

# 1 = nearest neighbor
# 2 = small world, power law
# 3 = random
# 4 = small world, strogatz
topology = 1
psyn = 0.5
esyn = -80


a = []
def randn(m, s, n):
	# generate a normally distributed random number with mean=0 and std=1
	for r in range(n):
		a.append(random.normalvariate(m,s))
	return a
    
def writesyn(pre, post, syn):
    if (syn == 0): esyn = '-60'
    if (syn == 1): esyn = '-10'
    if (syn == 2):
        rsyn = random.randint(0,1)
        if (rsyn): esyn = '-60'
        else: esyn = '-10'
        
    f.write('>' + str(pre) + ',' + str(post) + '1,' + str(esyn) + '\n')
    
# generate random numbers
a = randn(200,20,numcells)

f = open('nets/sm.net','w')

# generate cells
f.write('# Cells\n');
for r in a:
	f.write('@' + '9,' + str(r) + '\n')


# generate synapses 
f.write('\n\n# Synapses\n')

cnt = 0
tot = 0

if (topology == 1):
    
    f.write('# Using nearest neighbor connectivity\n')
    
    # connect each cell to its neighbor
    for i in range(len(a)):
        if ((i + 1) < len(a)):
            writesyn(i, i+1, 0)
            writesyn(i+1, i, 0)
            cnt = cnt + 2
            
    # connect around end of ring
    if (len(a) > 2):
        writesyn(0,len(a)-1,0)
        writesyn(len(a)-1,0,0)
        cnt = cnt + 2
        
    tot = len(a) * 2

if (topology == 2):
    
    f.write('# Using small world with power law connectivity\n')
    
    base = 1.06
    
    # power law for connection probability
    for i in range(len(a)):
        myrand = random.random()
        meannum = -math.log(myrand) / math.log(base);
        pconn = meannum / numcells
        pconn = pconn / 10
        
        for j in range(len(a)):
            
            tot = tot + 1
            if (pconn > random.random()):
                writesyn(i,j,0)
                cnt = cnt + 1
            
if (topology == 3):
    
    f.write('# Using random connectivity\n')

    for i in range(len(a)):
        for j in range(len(a)):
            tot = tot + 1
            print('testing ' + str(i) + ' and ' + str(j))
            if (random.random() < psyn):
                #add in a synapse between this pair
                writesyn(i,j,0)
                cnt = cnt + 1
                
if (topology == 4):
    
    f.write('# Using Strogatz style small worldness\n')
    
    for i in range(len(a)):
        if ((i + 1) < len(a)):
            
            if (psyn > random.random()):
                # rewire 
                dest = random.randint(0, len(a)-1)
                writesyn(i, dest, 0)
                print 'rewire', i, 'to', dest
            else:
                # keep nearest neighbor
                writesyn(i, i+1, 0)
                
            if (psyn > random.random()):
                dest = random.randint(0, len(a)-1)
                writesyn(i+1, dest, 0)
                print 'rewire', i+1, 'to', dest
            else:
                writesyn(i+1, i, 0)
            cnt = cnt + 2
            
    # connect around end of ring (not doing SM here)
    if (len(a) > 2):
        writesyn(0,len(a)-1,0)
        writesyn(len(a)-1,0,0)
        cnt = cnt + 2
        
    tot = cnt
    
            
print cnt, 'of', tot, 'syns\n'
