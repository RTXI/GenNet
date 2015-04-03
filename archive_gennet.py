# Python script to create a zip archive of all the souce code
# of GenNet suitable for distribution

import os
import zipfile

def keep_file(f):
    keep_list = ['.cpp', '.h', '.py', '.m', '.pl', 'Makefile']
    return any([f.endswith(ending) for ending in keep_list])
    
zfile = zipfile.ZipFile("GenNet.zip", "w")

for root, dirs, files in os.walk('../GenNet/'):
    for f in files:
        if(keep_file(f)):
            print ('%s/%s' % (root, f))
            # the second argument is the path inside the zip file
            # for that path remove the '../' from the root (first three chars)
            zfile.write('%s/%s' % (root, f), '%s/%s' % (root[3:], f))
            
            
zfile.close()
