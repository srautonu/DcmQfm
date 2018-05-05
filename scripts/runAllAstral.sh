#!/bin/sh

# Command line parameters
inputFolder=$1
inputGeneTree=genetrees

scoresFile=astralScore.csv

astral=$HOME/Research/dcm/Astral/astral.5.6.1.jar

maxDataset=20

for i in $(seq -f "%02g" 1 $maxDataset); do
  echo ========= Running ASTRAL for $inputFolder/$i ========

  echo Iteration,nQuartets > $inputFolder/$i/$scoresFile  
  echo -n ASTRAL, >> $inputFolder/$i/$scoresFile

  java -jar $astral -i $inputFolder/$i/$inputGeneTree -o $inputFolder/$i/astral.tre 2>&1 >/dev/null | grep "Final quartet score is:" | tr -d ' ' | cut -d ':' -f 2 >> $inputFolder/$i/$scoresFile
done


