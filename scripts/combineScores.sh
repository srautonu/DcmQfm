#!/bin/sh

inputFolder=$1
resultFile=$inputFolder/out.txt

echo Results will be stored in $resultFile

rm -f $resultFile
for i in $(seq -f "%02g" 1 20); do
  echo ==== $i ==== >> $resultFile 
  cat $inputFolder/$i/score.csv >> $resultFile
  cat $inputFolder/$i/astralScore.csv >> $resultFile
done


