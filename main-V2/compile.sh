#!/bin/sh

sh build.sh 

cd build 
make VERBOSE=1
cd ..

## /// MEMO
## VERBOSE=1 ... to show the detail in compile process 
##
##
