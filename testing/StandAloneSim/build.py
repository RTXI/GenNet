# This is an alternate build script based on fabricate.py
# (http://code.google.com/p/fabricate/)
# It is experimental and is not yet recommended for general use.
# This build script should work on all platforms (but is basically untested).

import sys
import os
from fabricate import *

srcdir = '.'
libdir = '.'

cc = 'g++'
cflags = '-O2 -Wall -ansi'.split()
exe = 'gn'

# scan for cpp files
sources = [f .replace('.cpp', '') for f in os.listdir(srcdir) if f.endswith('.cpp') and f != 'TestLogger.cpp']
objects = [f + '.o' for f in sources]
headers = [f + '.h' for f in sources]


def build():
    compile()
    link()

def compile():
    for source in sources:
        run('g++', cflags, '-c', source + '.cpp')

def link():
    run('g++', '-o', exe, objects)

def clean():
    autoclean()

main()
