#!/lusr/bin/python
'''
Created on Jun 3, 2011

@author: smirarab, modified by Bayzid
'''
import dendropy
import sys
import os
import copy
import os.path

if __name__ == '__main__':

    treeName = sys.argv[1]
    sample = open(sys.argv[2])
    included = [s[:-1] for s in sample.readlines()]
    resultsFile="%s.%s" % (treeName, os.path.basename(sample.name))
    trees = dendropy.TreeList.get_from_path(treeName, 'newick', rooting='force-rooted')
    filt = lambda node: True if (node.taxon is not None and node.taxon.label not in included) else False
    for tree in trees:
        tree.prune_taxa([n.taxon for n in tree.nodes(filt)])

    print ("writing results to " + resultsFile)
    #trees.write(open(resultsFile,'w'),'newick',write_rooting=False)
    trees.write(path=resultsFile, schema="newick", suppress_rooting=True)
