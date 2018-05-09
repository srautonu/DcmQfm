#!/bin/sh

# Command line parameters
inputFolder=$1

maxDataset=20

for i in $(seq -f "%02g" 1 $maxDataset); do
  echo ========= Running experiment for $inputFolder/$i ========
  ./runOneExp.sh $inputFolder/$i
done


