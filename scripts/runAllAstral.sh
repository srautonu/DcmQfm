#!/bin/sh

# Command line parameters
inputFolder=$1
inputGeneTree=$2

scoresFile=astralScore.csv

astral=$HOME/Research/dcm/Astral/astral.5.6.1.jar

maxDataset=20

for i in `seq 1 $maxDataset`; do
  echo ========= Running ASTRAL for $inputFolder/R$i ========

  echo Iteration,nQuartets > $inputFolder/R$i/$scoresFile  
  echo -n ASTRAL, >> $inputFolder/R$i/$scoresFile

  java -jar $astral -i $inputFolder/R$i/$inputGeneTree -o $inputFolder/R$i/astral.tre 2>&1 >/dev/null | grep "Final quartet score is:" | tr -d ' ' | cut -d ':' -f 2 >> $inputFolder/R$i/$scoresFile
done


