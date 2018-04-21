#!/usr/bin/env python

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

import sys
import os
import getopt
import dendropy
import re
import math
#import HTML
import random, tempfile
import subprocess
import shutil

from optparse import OptionParser, OptionGroup
from reup.reup import supplyReup

from newick_modified.tree import parse_tree
from spruce.mrp import *

def main(argv):
    inputFile = ""
    outputFile = ""    
    iters = 100
    logFile = ""
    best = None
    directory = None
    weighted = False
    regular = False
    
    try:
        opts, args = getopt.getopt(argv, "i:o:l:n:b:d:w:r:", ["input=", "output=", "log=", "iter=", "best=", "dir=","weighted=", "regular="])
    except getopt.GetoptError:
        print "Error!"
            #usage()
        sys.exit(2)    
    for opt, arg in opts:
        if opt in ("-i", "--input"):
            inputFile = arg
        elif opt in ("-o", "--output"):
            outputFile = arg
        elif opt in ("-l", "--log"):
            logFile = arg
        elif opt in ("-n", "--iter"):
            iters = int(arg)
        elif opt in ("-b", "--best"):
            best = arg
        elif opt in ("-d", "--dir"):
            directory = arg
        elif opt in ("-w", "--weighted"):
            if arg == 'true':
                weighted = True
        elif opt in ("-r", "--regular"):
            if arg == 'true':
                regular = True;
                
            
    if (directory is not None):
        tempfile.tempdir = directory
    
    f = tempfile.NamedTemporaryFile()
    prefix = f.name
    f.close()
    
    path = os.getenv("FASTMRP")
    if weighted:    
        pipe = Popen("java -jar %s/mrp.jar %s %s.mrp NEXUS -weighted" % (path, inputFile, prefix), shell = True, stdout = PIPE, stderr = PIPE)
    else:
        pipe = Popen("java -jar %s/mrp.jar %s %s.mrp NEXUS" % (path, inputFile, prefix), shell = True, stdout = PIPE, stderr = PIPE)
        
    
    (out, err) = pipe.communicate()
    print err    

    
    #Grab the number of taxa/columns from the mrp file
    numTaxa = None
    numColumns = None
    mrpFile = open(prefix+".mrp", 'r')
    for line in mrpFile:
        regex = re.compile("dimensions\s+ntax\s*=\s*(\d+)\s+nchar\s*=\s*(\d+)")
        r = regex.search(line)
        if (r is None):
            continue
        else:
            (numTaxa, numColumns) = (int(r.groups()[0]), int(r.groups()[1]))
            break
    weight_string = None
    weightList = [0]
    for line in mrpFile:
        regex = re.compile("weights")
        r = regex.search(line)
        if (r is None):
            continue
        else:
            weight_string = line.replace("weights ", "").replace(";", "")
    
    if weight_string is not None:
        for curr in weight_string.split(', '):
            temp = curr.split(':')
            #print temp[0] + " " + str(float(temp[0]))
            #weightList.insert(temp[1], temp[0])
            weightList.insert(int(temp[1]), float(temp[0]))
    

        
    #Append the commands to run ratchet search at end of nexus file    
    f = open (prefix+".mrp", 'a')
    if not weighted and not regular:
        writeRatchetInputFile(None, f, filePrefix = prefix, numRatchetIterations = iters, numChars = numColumns)
    elif weighted and not regular:
        writeWeightedRatchetInputFile(None, f, filePrefix = prefix, numRatchetIterations = iters, weight = weightList, numChars = numColumns)
    elif weighted and regular:
        writeWeightedInputFile(None, f, filePrefix = prefix)
    elif not weighted and regular:
        writeWeightedInputFile(None, f, filePrefix = prefix)
    else:
        exit()
    f.close()


    
    pipe = Popen("./bin/paup -n %s.mrp" % prefix, shell = True, stdout = PIPE, stderr = PIPE)
    (out, err) = pipe.communicate()
    
    trees = None
    bestTrees = None
    trees = getConsensusTreesFromPaupFiles(prefix)
    if (best):
        mpTrees = readTreesFromRatchet(prefix+".tre.best")
        bestTrees = random.choice(mpTrees)

    try:
        if (logFile != ""):        
            shutil.copyfile(prefix + ".log", logFile)

        os.remove(prefix + ".log")
        os.remove(prefix + ".gmrp")
        os.remove(prefix + ".smrp")
        os.remove(prefix + ".mmrp")
        os.remove(prefix + ".tre")
#        if not weighted:
#            os.remove(prefix + ".tre.nex")
        os.remove(prefix + ".mrp")
    except:
        print "Error removing files\n"

    
                
    #print "My Dir: " + curDir
    
    output = trees['gmrp']        
    out = open(outputFile,"w")
    out.write(str(output))
    out.flush()
    out.close()
    
    if (best):
        out = open(best,"w")
        out.write(str(bestTrees))
        out.flush()
        out.close()
        try:
            os.remove(prefix + ".tre.best")
        except:
            print "Error removing files\n"

if __name__ == "__main__":
    main(sys.argv[1:])
