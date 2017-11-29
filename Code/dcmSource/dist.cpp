
#include <iostream>
#include "dist.h"

using namespace std;

DistMatrix::DistMatrix() {
    ntaxa=0;
    D=NULL;
}

void DistMatrix::read_distmatrix_by_fh(istream& ins, LABELMAP** lblmapv) {
    int i, j, ni;
    char t[256];

    LABELMAP* lblmap = new LABELMAP();
    *lblmapv=lblmap;
    int numlabel=0;

    
    ins >> ntaxa; 
    D = new float*[ntaxa];
    if (!D) {return;}
        
    for (i=0;i<ntaxa;i++) {
        D[i]=new float[ntaxa];
        if (!D[i]) {
            for (j=0;j<i;j++) {delete D[j];}
            return;
        }
    }

    ni=0;
    while(! ins.eof()) {
        ins >> t;
        lblmap->push_back(string(t));
        for (i=0;i<ntaxa;i++) {
            ins >> D[ni][i];
        }
        ni=ni+1;
        if (ni==ntaxa) {break;}       
    }
    return;
}


void DistMatrix::dump(ostream& outs){
    outs << ntaxa << endl;
    int i,j;
    for (i=0;i<ntaxa;i++) {
        for (j=0;j<ntaxa;j++) {
            outs << D[i][j] << "\t";
        }
        outs << endl;
    }    
}







    
