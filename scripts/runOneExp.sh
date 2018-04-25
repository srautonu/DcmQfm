#!/bin/sh

export FASTMRP=$HOME/Research/dcm/scripts/bin
export PATH=$PATH:$HOME/Research/dcm/standard-RAxML-master

# Command line parameters
expFolder=$1
startingTree=$2
trueTree=$3

geneTree=Best.1


# DCM parameters
subsetSize=15
paddingSize=1
maxIteration=5
completedIterations=0

cp $expFolder/$startingTree $expFolder/newTree.0

for i in `seq $((completedIterations+1)) $maxIteration`; do
  iterationFolder=$expFolder/iteration_$i

  # Create the iteration folder
  mkdir $iterationFolder
  
  startingTree=newTree.$((i-1))

  nSubsets=0

  # DACTAL decomposition into overlapping subsets
  python prd_decomp.py $expFolder/$startingTree $subsetSize $paddingSize  > $iterationFolder/dactal_subsets

  # Convert the subsets for subsequent consumption
  perl extract_subsets.pl -i $iterationFolder/dactal_subsets

  # Restrict the gene trees to the subsets of taxa
  cp $expFolder/$geneTree $iterationFolder/$geneTree
  for subsetFile in $iterationFolder/subsets.*; do
    python induced_subtree_from_taxa.py $iterationFolder/$geneTree $subsetFile
    nSubsets=$((nSubsets+1))
  done
  rm $iterationFolder/$geneTree

  # For the subset induced gene trees, compute the quartets count
  for j in `seq 1 $nSubsets`; do
    ./quartet-controller.sh $iterationFolder/$geneTree.subsets.$j $iterationFolder/quartets.$j
  done

  # Run WQFM on each set of quartets 
  for j in `seq 1 $nSubsets`; do
    bin/wqfm $iterationFolder/quartets.$j $iterationFolder/qfmTree.$j
  done

  # Merge all the qfm trees into single file
  rm -f $iterationFolder/qfmTreesCombined
  for j in `seq 1 $nSubsets`; do
    cat $iterationFolder/qfmTree.$j >> $iterationFolder/qfmTreesCombined
  done

  # Run Superfine+MRL
  python runReup.py -r rml $iterationFolder/qfmTreesCombined > $expFolder/newTree.$i
done

# Score all the newly generated species trees
./scoreTrees.sh $expFolder $geneTree

# Calculate the Fn score
./fnTrees.sh $expFolder $trueTree


