#!/bin/sh

export FASTMRP=$HOME/Research/dcm/scripts/bin

# Command line parameters
expFolder=$1
geneTree=$expFolder/Best.1
mrpTree=$expFolder/mrp.tre

python runWMRP_nam.py -i $geneTree -o $mrpTree -d $expFolder -r true
