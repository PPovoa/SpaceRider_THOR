#!/bin/bash
/usr/local/cuda-11.4/bin/nvcc -arch sm_72 -o build-out Funcs.cu THOR.cu Menu_Funcs.cu -L. -lpxcore -lminipix  -ldl -lm -lc -g
#[ ! -d "./output-files" ] && mkdir ./output-files
# build the Data Driven Mode example (ex-dataDriven.cpp) and create dirrectory for data saving
