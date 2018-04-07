#!/bin/sh

inputFolder=$1
resultFile=$inputFolder/out.txt

echo Results will be stored in $resultFile

rm $resultFile
for i in `seq 1 20`; do 
  echo ==== R$i ==== >> $resultFile 
  cat $inputFolder/R$i/score.csv >> $resultFile
  cat $inputFolder/R$i/astralScore.csv >> $resultFile
done


