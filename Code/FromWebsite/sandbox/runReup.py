#!/usr/bin/python

###########################################################################
##    Copyright 2010 Rahul Suri and Tandy Warnow.
##    This file is part of ReUP.
##
##    ReUP is free software: you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation, either version 3 of the License, or
##    (at your option) any later version.
##
##    ReUP is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with ReUP.  If not, see <http://www.gnu.org/licenses/>.
###########################################################################

from optparse import OptionParser, OptionGroup
from reup.reup import supplyReup

def parseOptions (commandLine = None):
    '''Parse command line for options'''

    desc = ' '.join(['This script runs the SuperFine algorithm on a set of input trees',  
                     'given in a file, in Newick format.'])

    parser = OptionParser(usage = "usage: %prog [options] input_trees_file > output", 
                          version = "%prog 1.0", 
                          description = desc)

    parser.set_defaults(reconciler = "qmc",
                        numIters = 100, 
                        writeData = None)

    group4InfoString = ' '.join(["These options enable selection of the supertree", 
                                 "algorithm to be used as a subroutine within", 
                                 "SuperFine for resolving polytomies.  The 'qmc'",
                                 "option requires that Quartets MaxCut be", 
                                 "installed; the 'gmrp' (greedy consensus of MP", 
                                 "trees) and 'rmrp' (random MP tree) options", 
                                 "require that PAUP* be installed.  Note that", 
                                 "the selected subroutine's binary must be in", 
                                 "the system's executable search path."])

    group5InfoString = ' '.join(["This option causes output of both the final", 
                                 "SuperFine tree and the corresponding SCM tree", 
                                 "to be written to disk.  Both are written to", 
                                 "the directory containing the source trees", 
                                 "file, and the specified suffix is appended to", 
                                 "each one's name."])

    group4 = OptionGroup(parser, "Quartet Tree Reconciliation Options".upper(), group4InfoString)
    group5 = OptionGroup(parser, "Data Output Options".upper(), group5InfoString)

    group4.add_option("-r", "--reconcile", choices = ("qmc", "gmrp", "rmrp"), 
                      dest = "reconciler", metavar = "ALG", 
                      help = "use ALG to reconcile relabeled trees, "
                             "where ALG is one of {qmc, gmrp, rmrp} "
                             "[default: %default]")
    group4.add_option("-n", "--numIters", type = "int", 
                      dest = "numIters", metavar = "N", 
                      help = "use N ratchet iterations when resolving with MRP "
                             "[default: %default]")

    group5.add_option("-w", "--write", dest = "writeData", metavar = "SUFFIX",  
                      help = "write merger tree and final tree to disk in same "
                             "directory as source trees file, append .SUFFIX "
                             "to written file names "
                             "[default: %default]")

    parser.add_option_group(group4)
    parser.add_option_group(group5)

    if commandLine:
         (options, args) = parser.parse_args(commandLine)
    else:
        (options, args) = parser.parse_args()

    if len(args) != 1:
        parser.error("Incorrect number of arguments. Try the -h flag for help.")

    input = args[0]

    return (input, options)


# MAIN
if __name__ == '__main__':
    (input, options) = parseOptions()
    supplyReup(input, options)
