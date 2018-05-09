#!/bin/sh

inputFolder=$1
resultFile=$inputFolder/outFN.txt

echo Results will be stored in $resultFile

rm -f $resultFile
for i in $(seq -f "%02g" 1 20); do
  echo ==== $i ==== >> $resultFile 
  cat $inputFolder/$i/fn.csv >> $resultFile
done


