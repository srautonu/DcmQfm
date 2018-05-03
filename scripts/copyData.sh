#!/bin/sh

dataFolder=$HOME/Research/dcm/data/ASTRAL-II

targetFolder=$1

pushd $targetFolder

for model in $(ls $dataFolder/true-specis-trees); do
  mkdir $model
  pushd $model
  for i in {01..20}; do
    mkdir $i
    pushd $i
    cp $dataFolder/true-specis-trees/$model/$i/* .
    cp $dataFolder/true-gene-trees/$model/$i/* .
    cp $dataFolder/estimated-gene-trees/$model/$i/* .
    popd
  done
  popd
done

popd


