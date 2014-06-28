# Run sweep in python!

import re
import os
import sys
import DataDirs

# global to count how many runs we did
nruns = 0

# produce a range of numbers
def rangef(start = 1, end = 2, step = .2):
    while start < end:
        yield start
        start = start + step

# print a list as a nice string
def makeListStr(l):
    res = ''
    tmp = ['%0.2f' % s for s in l]
    tmp = [s.replace('.', '_') for s in tmp]
    res = '-'.join(tmp)
    return res
    #for s in l: 
    #    tmp = s.replace('.','_')
    #    res = ('
    #return res
        
# recursive function to run our sims
def runsim(lines, stack):
    
    global nruns
    #print '--- function called ---'
    pat = 'rangef\(.*\)'
    p = re.search(pat, lines)
    for runval in eval(p.group()):

        # sub in the new value
        mysm = re.sub(pat, str(runval), lines, 1)

        # save the variable we're currently on
        stack.append(runval)

        # if there is something else to replace, recurse
        if (re.search(pat, mysm)):
            runsim(mysm, stack)
            stack.pop()
        else:
            print 'Running sim for ' + "(" + str(['%0.3f' % s for s in stack]) + ')'
    
            # sub in the single value for this one run and write the file out
            open("nets/mysm.net","w").write(mysm)

            # do the run
            os.system('./gn -p nets/mysm.net')

            # copy the files
            for suffix in ['dat','info']:
                os.system('cp DATA/' + DataDirs.getNowFileName(suffix) + ' ' +
                    resdir + makeListStr(stack) + '.' + suffix)

            # finally, copy input netfile and make link to data dir
            os.system('cp ' + myfile + ' ' + resdir + os.path.basename(myfile))
            print 'Copied to: ' + resdir + makeListStr(stack) + '\n'

            # pop vector and update count
            stack.pop()
            nruns = nruns + 1


# beginning of script
if __name__ == '__main__':
    
    # simulation params
    myfile = 'nets/sm.net'
    pat = 'rangef\(.*\)'

    # replace comments
    lines = open(myfile).read()
    lines = re.sub('#.*','',lines)
    
    # check for sweep statements
    if (re.search(pat, lines) == None):
        print 'Found no sweeps'
        sys.exit()

    # make result directory
    resdir = DataDirs.makeNowDir()
    # create a link to the most recent data dir (for easy analysis)
    if (os.path.islink('DATA/latest')):
        os.remove('DATA/latest')
    # remove the first part of the path    
    os.symlink(resdir.split('/',1)[1], 'DATA/latest')


    # begin recursion
    runsim(lines, [])

    print "Saved " + str(nruns) + " data files to " + resdir 

