dactal (See commands from the paper)
------

dactal subset creation using prd_decomp.py
Create separate subset files by running extract_subsets.pl
Create gene tress scoped to the specified subsets using induced_subtree_from_taxa.py

quartets
--------

./quartet-controller <SubSetSpeciesTreeFile> <FileToStoreQuartets>

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
