#!/bin/sh

# Command line parameters
inputFolder=$1
inputGeneTree=genetrees
mrpTree=mrp.tre

export FASTMRP=$HOME/Research/dcm/scripts/bin

maxDataset=20

# MRP seems to have some issues with long paths. 
# So we will copy the gene tree to a temp folder first
tempFolder=$(mktemp -d)

for i in $(seq -f "%02g" 1 $maxDataset); do
  echo ========= Running MRP for $inputFolder/$i ========

  cp $inputFolder/$i/$inputGeneTree $tempFolder/$inputGeneTree

  python runWMRP_nam.py -i $tempFolder/$inputGeneTree -o $tempFolder/$mrpTree -d $tempFolder -r true
  mv $tempFolder/$mrpTree $inputFolder/$i/$mrpTree

  rm $tempFolder/*
done

rmdir $tempFolder


