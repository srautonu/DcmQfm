#!/bin/sh

export FASTMRP=$HOME/Research/dcm/scripts/bin
export PATH=$PATH:$HOME/Research/dcm/standard-RAxML-master

expFolder=`mktemp -d -p $HOME/Research/dcm/run`

# Command line parameters
inputFolder=$1
geneTree=$2
startingTree=$3

# DCM parameters
subsetSize=15
paddingSize=4
maxIteration=5
completedIterations=0

cp $inputFolder/$startingTree $inputFolder/newTree.$completedIterations

for i in `seq $((completedIterations+1)) $maxIteration`; do

  # Delete all content of the exp folder
  rm $expFolder/*

  startingTree=newTree.$((i-1))

  cp $inputFolder/$geneTree $expFolder
  cp $inputFolder/$startingTree $expFolder 

  nSubsets=0

  # DACTAL decomposition into overlapping subsets
  python prd_decomp.py $expFolder/$startingTree $subsetSize $paddingSize  > $expFolder/dactal_subsets

  # Convert the subsets for subsequent consumption
  perl extract_subsets.pl -i $expFolder/dactal_subsets

  # Restrict the gene trees to the subsets of taxa
  for subsetFile in $expFolder/subsets.*; do
    python induced_subtree_from_taxa.py $expFolder/$geneTree $subsetFile
    nSubsets=$((nSubsets+1))
  done

  # For the subset induced gene trees, compute the quartets count
  for j in `seq 1 $nSubsets`; do
    ./quartet-controller.sh $expFolder/$geneTree.subsets.$j $expFolder/quartets.$j
  done

  # Run WQFM on each set of quartets 
  for j in `seq 1 $nSubsets`; do
    bin/wqfm $expFolder/quartets.$j $expFolder/qfmTree.$j
  done

  # Merge all the qfm trees into single file
  rm $expFolder/qfmTreesCombined
  for j in `seq 1 $nSubsets`; do
    cat $expFolder/qfmTree.$j >> $expFolder/qfmTreesCombined
  done

  # Run Superfine+MRL
  python runReup.py -r rml $expFolder/qfmTreesCombined > $expFolder/newTree.$i

  cp $expFolder/newTree.$i $inputFolder/newTree.$i
done

# Score all the newly generated species trees
./scoreTrees.sh $inputFolder $geneTree


