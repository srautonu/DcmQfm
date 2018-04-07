#!/bin/sh

# Command line parameters
inputFolder=$1
inputGeneTree=$2
startingTree=$3

maxDataset=20

for i in `seq 1 $maxDataset`; do
  echo ========= Running experiment for $inputFolder/R$i ========
  ./runOneExp.sh $inputFolder/R$i $inputGeneTree $startingTree
done


