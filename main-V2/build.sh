#!/bin/sh
mkdir build 
cd build 

## /// Release
cmake \
-DCMAKE_BUILD_TYPE=Release \
../src 

## /// Debug
# cmake \
# -DCMAKE_BUILD_TYPE=Debug \
# ../src 

cd ..

