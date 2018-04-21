for f in $(ls); do
  for i in `seq 1 20`; do
    mv $f/R$i/Best.1.tre $f/R$i/mpest.tre 
  done
done

for i in `seq 1 20`; do
  ./fnTrees.sh ../data/mammals/true.tre ../results/MRP_15_01/noscale.200g.500b/R$i/ 
done




/home/saifur/Research/dcm/run/tmp.Zp6hcn2l9N
noscale.100g.500b/R10

## Script to check a matching Best.1 in the data set
# Useful for debugging a result
for f in ../../data/mammals/*; do
  for i in `seq 1 20`; do
    if diff Best.1  $f/R$i/Best.1 >/dev/null 2>&1; then
      echo "Matched with $f/R$i";
    fi
  done
done



cut -d ' ' -f 1-

https://github.com/srautonu/DcmQfm.git


Data
----
The starting tree is created using what? [There was some confusion]

dactal (See commands from the paper)
------

dactal subset creation using prd_decomp.py
Create separate subset files by running extract_subsets.pl
Create gene tress scoped to the specified subsets using induced_subtree_from_taxa.py

quartets
--------

Modify one line in "quartet_count.sh" file -- "/projects/sate7/tools/bin/triplets.soda2103".
Replace the path "/projects/sate7/tools/bin" by indicating your local directory where you saved "triplets.soda2013".

Then run the following command:

quartet-controller.sh <inputFile> <outputFile>

<inputFile>: a file containing the gene trees in newick format.
<outputFIle>: it will contain all the induced quartets and their frequency.

WQFM
----

WQFM_Final.cpp should work fine. 
WQFM_Final_newInitial.cpp is a slightly modified version where Rezwana implemented a different initial partitioning method for the set of taxa. This version is not yet tested extensively.

The perl script "reroot_tree_new.pl" should be saved in the same directory as WQFM_Final. It requires bioPerl-1.5.2

superFine
---------

export FASTMRP= Directory of mrp.jar
export PATH = %PATH: Directory of RAxML

Add import copy at the beginning of scm.py DendroPy-3.8.1\dendropy folder and the copy of it inside the build folder.

Download reup-1.1 and modified runReup.py from: https://www.dropbox.com/s/ujhn4sjdgfvrv8g/reup.tar.gz?dl=0

Once you install the reup, change line number 72 and 82 in <installation directory>/lib/python/reup/adapters.py. Replace '3' with '2' in these two lines.

PAUP and mrp.jar must be in the same folder as the python script

newick modified package (1.3.1) was taken from Bayzid's local copy. The ones hosted in Github or other places did not work.

# To resolve non-binary, run the following on the new sp tree. This generates new_sp_tree.resolved
python arb_resolve_polytomies_new.py new_sp_tree

Score using Astral
------------------
java -jar astral.5.6.1.jar -q <spTree> -i geneTree -o score 2> logFile

java -jar $HOME/Research/dcm/Astral/astral.5.6.1.jar -q newTree.0 -i InputGeneTrees -o score 2> logFile


Score SP trees
--------------
Strip the "all gene trees" of edge support information
Strip the new_sp_tree of the edge support information
Run the script for scoring


