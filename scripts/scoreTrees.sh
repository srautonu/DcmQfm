#!/bin/sh

astralFolder=$HOME/Research/dcm/Astral
astralJar=astral.5.6.1.jar

# Command line parameters
treeFolder=$1
geneTree=$treeFolder/$2

scoresFile=$treeFolder/score.csv

echo -n Saving scores to $scoresFile ...

echo Iteration,nQuartets > $scoresFile

for counter in `seq 0 5`; do

 treeFile=$treeFolder/newTree.$counter

 echo -n $counter, >> $scoresFile

 java -jar $astralFolder/$astralJar -q $treeFile -i $geneTree 2>&1 >/dev/null | grep "Final quartet score is:" | tr -d ' ' | cut -d ':' -f 2 >> $scoresFile

 counter=$((counter+1))
done

echo  done.


