#ifndef __DIST_H
#define __DIST_H

#include <iostream>
using namespace std;

#define INFDIST 1e30
#include "tree.h"

class DistMatrix {
    public:
        int ntaxa;
        float** D;
        DistMatrix();
        void read_distmatrix_by_fh(istream& ins,LABELMAP** lblmapv);
        void dump(ostream& outs);
};
#endif
