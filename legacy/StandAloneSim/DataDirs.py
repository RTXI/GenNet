
from time import strftime
import time
import os


# unused now
def prependZero(num):
    if(num < 10):
        return '0' + str(num)
    else:
        return str(num)
        
def makeNowDir():
    # this way was cool, but overly complicated
    #(year,month,day,hour,minutes,sec,wday,yday,dst) = time.localtime()
    #datadir = ":".join(map(self.prependZero,[hour,minutes,sec]))
    
    # make the day's dir and the time's dir
    # (certain operating systems don't allow ':' in filenames)
    mypath = 'DATA/saved/' + strftime('%b%d/%H:%M:%S/',time.localtime())   
    os.makedirs(mypath)    
    
    return mypath
    
def getNowFileName(suffix = 'dat'):
    return strftime('GenNet_%b_%d_%y_A1.' + suffix, time.localtime())
    
if __name__ == '__main__':
    
    makeNowDir()
    print getNowFileName()



