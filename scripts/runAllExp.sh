#!/bin/sh

# Command line parameters
inputFolder=$1
subsetSize=$2
paddingSize=$3

maxDataset=20

for i in $(seq -f "%02g" 1 $maxDataset); do
  echo ========= Running experiment for $inputFolder/$i ========
  ./runOneExp.sh $inputFolder/$i $subsetSize $paddingSize 
done


