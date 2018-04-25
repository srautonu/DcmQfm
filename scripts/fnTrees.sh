#!/bin/sh

# Command line parameters
expFolder=$1
trueTree=$2

fnFile=$expFolder/fn.csv

echo -n Saving FP, FN and Robinson-Foulds to $fnFile ...

echo Iteration,FP,FN,RF > $fnFile

for counter in `seq 0 5`; do

 estTree=$expFolder/newTree.$counter

 echo -n $counter, >> $fnFile
 python getFpFn.py -t $trueTree -e $estTree |  tr -d "() "  >> $fnFile

 counter=$((counter+1))
done

# ASTRAL FN rate
estTree=$expFolder/astral.tre

echo -n ASTRAL, >> $fnFile
python getFpFn.py -t $trueTree -e $estTree |  tr -d "() "  >> $fnFile

echo  done.


