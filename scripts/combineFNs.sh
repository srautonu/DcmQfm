#!/bin/sh

inputFolder=$1
resultFile=$inputFolder/outFN.txt

echo Results will be stored in $resultFile

rm -f $resultFile
for i in `seq 1 20`; do 
  echo ==== R$i ==== >> $resultFile 
  cat $inputFolder/R$i/fn.csv >> $resultFile
done


