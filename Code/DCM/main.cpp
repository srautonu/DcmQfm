#include <iostream>
#include <stdlib.h>

#include "dist.h"
#include "graph.h"
#include "tree.h"
#include "dcm.h"

#define INPUT_NEWICK_STRING_CHAR_BUFFER_LOG2_SIZE 26;

using namespace std;

void usage() {
    cout << "Usage: dcm <type> <infile> <param>" << endl;
    cout << "    type    : 1: DCM-1, 2: DCM-2, 3: DCM-3, 4: DCM-4, m: MedianEdge, p: Adaptive DCM-4" << endl;
    cout << "    infile, param: input specification" << endl;
    cout << "      DCM-1, DCM-2: infile=distance matrix, param=threshold " << endl;
    cout << "      DCM-3, DCM-4, MedianEdge: infile=guide tree, param=padding constant " << endl;
    cout << "      Adaptive DCM-4: infile=guide tree, param=max subprob size " << endl;
    cout << "    For any problems, bugs, etc. please email to Li-San <lisan@cs.utexas.edu> " << endl;
}    

int main(int argc, char** argv) {
    char* instr;  
    double threshold;
    int param;
    RootedTree* rt;
    LABELMAP* lblmap;

    int inputNewickStringBufferSize = 1 << INPUT_NEWICK_STRING_CHAR_BUFFER_LOG2_SIZE;
    
    instr = new char[inputNewickStringBufferSize];   // 64 MB

    cerr << "Using " << inputNewickStringBufferSize << " bytes for input newick parsing." << endl;

    if (argc!=4) { usage();
       exit(1);
    }

    fstream filestr (argv[2], fstream::in);
    Decomp* dsp;

    
    char typeidx=argv[1][0];
    
    if (typeidx=='1' || typeidx=='2') {
        threshold=atof(argv[3]);
        DistMatrix DM;            // Read input distance matrix
        DM.read_distmatrix_by_fh(filestr,&lblmap);
        filestr.close();
        
        DCMGraph g;
        g.asThresholdGraph(DM,(float) threshold);
        if (!g.connected()) {
            cout << "Threshold graph not connected!" << endl;
            exit(1);
        }
        
        if (typeidx=='1') { // DCM-1
            DCM1_Factory df1;
            dsp=df1.decompose(DM,threshold);
        } else {            // DCM-2  
            DCM2_Factory df2;
            dsp=df2.decompose(DM,threshold);
        }
    } else if (typeidx=='3' || typeidx=='4' || typeidx=='m' || typeidx=='p') { 
        param=atoi(argv[3]);

        filestr >> instr;
        filestr.close();
        
        UnrootedTreeParser utp;
        UnrootedTree* tree=utp.parse_newick(instr, &lblmap);
        
        if (typeidx=='3') {                    // DCM-3
            DCM3_Factory df3;
	    // this is where the bulk of the processing is - the decomposition itself
            dsp=df3.decompose(tree,param);
        } else if (typeidx=='4') {             // DCM-4  
            DCM4_Factory df4;
            dsp=df4.decompose(tree,param);
        } else if (typeidx=='m') {             // Median Edge 
            MEDecomp_Factory dfm;
            dsp=dfm.decompose(tree,param);                    
        } else {                               // Adaptive DCM-4
            AdaptiveDCM4_Factory dfm;
            dsp=dfm.decompose(tree,param);                    
        }

	// responsibility of caller to delete the UnrootedTree object that's 
	// returned from UnrootedTreeParser::parse_newick
	delete(tree);

    } else {         // Wrong type
        cout << "Wrong decomposition type " << typeidx << endl;
        usage();
        exit(1);
    }    
    cout << "decomposition:" << endl;
    dsp->dump(cout,*lblmap);
    
    delete [] instr;

    // responsibility of caller to free dynamically allocated LABLEMAP
    // from UnrootedTreeParser::parse_newick
    delete(lblmap);

    // delete dsp 
    delete(dsp);
}
















