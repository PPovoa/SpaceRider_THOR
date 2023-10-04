#!/bin/bash
/usr/local/cuda-11.4/bin/nvcc -arch sm_72 -o build-out Debug.cu Commissioning.cu Housekeeping.cu Observational.cu SCI_data.cu THOR.cu -L. -lpxcore -lminipix -ldl -lm -lc -g
#[ ! -d "./output-files" ] && mkdir ./output-files
# build the Data Driven Mode example (ex-dataDriven.cpp) and create dirrectory for data saving
