#!/bin/sh

dataFolder=$HOME/Research/dcm/data/ASTRAL-II

targetFolder=$1

mkdir $targetFolder/true
mkdir $targetFolder/estimated
mkdir $targetFolder/estimatedResolved

for  model in $(ls $dataFolder/true-specis-trees); do
  mkdir $targetFolder/true/$model
  mkdir $targetFolder/estimated/$model
  mkdir $targetFolder/estimatedResolved/$model

  for i in $(seq -f "%02g" 1 20); do
    mkdir $targetFolder/true/$model/$i
    mkdir $targetFolder/estimated/$model/$i
    mkdir $targetFolder/estimatedResolved/$model/$i

    cp $dataFolder/true-gene-trees/$model/$i/truegenetrees $targetFolder/true/$model/$i/genetrees
    cp $dataFolder/estimated-gene-trees/$model/$i/estimatedgenetre.halfresolved $targetFolder/estimatedResolved/$model/$i/genetrees

    # the estimated gene tree may or may not be in .gz zipped form
    if [ -f $dataFolder/estimated-gene-trees/$model/$i/estimatedgenetre.gz ]; then
       cp $dataFolder/estimated-gene-trees/$model/$i/estimatedgenetre.gz $targetFolder/estimated/$model/$i/genetrees.gz
       gunzip $targetFolder/estimated/$model/$i/genetrees.gz
    else
       cp $dataFolder/estimated-gene-trees/$model/$i/estimatedgenetre $targetFolder/estimated/$model/$i/genetrees
    fi

    # now copy the true species tree in each (true/estimated/estimatedResolved) folder
    cp $dataFolder/true-specis-trees/$model/$i/s_tree.trees $targetFolder/true/$model/$i/trueSPTree
    cp $dataFolder/true-specis-trees/$model/$i/s_tree.trees $targetFolder/estimated/$model/$i/trueSPTree
    cp $dataFolder/true-specis-trees/$model/$i/s_tree.trees $targetFolder/estimatedResolved/$model/$i/trueSPTree
  done
done

