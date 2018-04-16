#!/bin/sh

# Command line parameters
inputFolder=$1
startingTree=$2

maxDataset=20

for i in `seq 1 $maxDataset`; do
  echo ========= Running experiment for $inputFolder/R$i ========
  ./runOneExp.sh $inputFolder/R$i $startingTree
done


