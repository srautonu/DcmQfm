#! /usr/bin/python

import sys
from PRD import PRDWrapper

if ( __name__ == '__main__' ) :
    filepath = sys.argv[1]
    subset = int(sys.argv[2])
    overlap = int(sys.argv[3])
    dec = PRDWrapper(subset, overlap)
    output = dec.decompose_dataset(filepath)
    for i, subset in enumerate(output) :
        print('subset {0:2d}: {1}'.format(i, subset))
