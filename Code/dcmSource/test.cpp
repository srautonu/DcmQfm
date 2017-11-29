#include <iostream>
#include <stdlib.h>

#include "dist.h"
#include "graph.h"
#include "tree.h"
#include "dcm.h"

using namespace std;

int main(int argc, char** argv) {
    char instr[65536];
    RootedTree* rt;

// Test tree.cpp
/*
    fstream filestr (argv[1], fstream::in);
    filestr >> instr;
    filestr.close();

    RootedTreeParser rtp;

    rt=rtp.parse_newick(instr);
    rt->print_rootedtree(cout);
    cout << endl;
    
    RTDFSIterator ri(rt);
    while(!ri.at_end()) {
        cout << ri.current()->label << endl;
        ri.next();
    }    
    

    UnrootedTree* ut=new UnrootedTree(rt); 
    ut->dump(cout);
    
    UTDFSIterator di(ut,ut->startnode);
    while(!di.at_end()) {
        cout << di.current() << endl;
        di.next();
    }    
    cout << di.current();
    
    UTEuclideanTourIterator eti(ut);
    const int* el;
    while(!eti.at_end()) {
        el=eti.current();
        cout << el[0] << " " << el[1] << endl;
        eti.next();
    }
    
    delete rt;
*/

// Test dist.cpp

/* 
    fstream filestr2 (argv[2], fstream::in);
    DistMatrix DM;
    DM.read_distmatrix_by_fh(filestr2);
    filestr2.close();
    
    DM.dump(cout);

    Graph g;
    g.asThresholdGraph(DM,3.0);
    cout << "Number of nodes: " << g.nnodes << endl;
    cout << "Nodelist: " << g.nodelist << endl;
    g.dump(cout);
    cout << endl;
    cout << "Graph connected: " << g.connected() << endl;
    
    int i,j;
    for (i=0;i<g.nnodes;i++) {
        for (j=0;j<g.nnodes;j++) {
            cout << "Node " << i << "," << j << " dist: " << DM.D[i][j] << " adj: " << g.isadj(i,j) << endl;
        }
    }
    
    GraphDFSIterator gdfsi(&g, 5);
    int node;
    j=0;
    while(!gdfsi.at_end()) {
        node=gdfsi.current();
        cout << "Yield " << j << ":" << node  << endl;
        gdfsi.next();
        j++;
    }
    
*/
   
// Test dcm.cpp
/*
    fstream filestr2 (argv[1], fstream::in);
    DistMatrix DM;
    DM.read_distmatrix_by_fh(filestr2);
    filestr2.close();
    
    float threshold;
    sscanf(argv[2],"%f",&threshold);

    DCMGraph g;
    g.asThresholdGraph(DM,threshold);
    if (!g.connected()) {
        cout << "Threshold graph not connected!" << endl;
        exit(1);
    }

    cout << "Triangulate..." << endl;
    PEO* peo0;
    peo0=g.GreedyTriangulate();
    peo0->dump(cout);
    
    cout << "PEO..." << endl;
    PEO* peo;
    peo=g.PerfectEliminationOrdering();
    peo->dump(cout);
    
    cout << "DCM-1 decomposition using greedy heuristic subroutine peo..." << endl;
    Decomp* dsp;
    dsp=g.EnumerateMaxCliques(peo0);
    dsp->dump(cout);

    cout << "DCM-1 decomposition using computed peo..." << endl;
    Decomp* dsp2;
    dsp2=g.EnumerateMaxCliques(peo);
    dsp2->dump(cout);


// DCM-1 test

    cout << "Test DCM-1\n";
    Decomp* dsp3;
    DCM1_Factory df1;
    dsp3=df1.decompose(DM,threshold);
    dsp3->dump(cout);
 
// DCM-2 test    
    cout << "Test DCM-2\n";
    Decomp* dsp4;
    DCM2_Factory df2;
    dsp4=df2.decompose(DM,threshold);
    dsp4->dump(cout);
*/     

// Test UnrootedTree DFS
/*
    fstream filestr (argv[1], fstream::in);
    filestr >> instr;
    filestr.close();


    RootedTreeParser rtp;

    rt=rtp.parse_newick(instr);
    rt->print_rootedtree(cout);
    cout << endl;

    UnrootedTree* ut=new UnrootedTree(rt); 
    ut->dump(cout);
    
    // DFS
    UTDFSIterator eti(ut,ut->startnode);
    int v;
    while(!eti.at_end()) {
         v=eti.current();
         eti.next();
         cout << v << " " << ut->nodelist[v]->label << endl;
    }   
    delete rt;
*/

// Test MedianEdgeDecomposition
/*    fstream filestr (argv[1], fstream::in);
    filestr >> instr;
    filestr.close();
    UnrootedTreeParser utp;
    UnrootedTree* tree=utp.parse_newick(instr);

    MEDecomp_Factory medf;
    Decomp* dcp=medf.decompose(tree,1);

    cout << "Median Edge Decomposition: " << endl;
    dcp->dump(cout);
*/

// Test DCM-3
/*    fstream filestr (argv[1], fstream::in);
    filestr >> instr;
    filestr.close();
    UnrootedTreeParser utp;
    UnrootedTree* tree=utp.parse_newick(instr);

    DCM3_Factory dcm3f;
    Decomp* dcp=dcm3f.decompose(tree,1);
    cout << "DCM-3 Decomposition: " << endl;

    dcp->dump(cout);
*/
// Test DCM-4
    fstream filestr (argv[1], fstream::in);
    filestr >> instr;
    filestr.close();
    UnrootedTreeParser utp;
    UnrootedTree* tree=utp.parse_newick(instr);

    DCM4_Factory dcm4f;
    Decomp* dcp=dcm4f.decompose(tree,1);
    cout << "DCM-4 Decomposition: " << endl;

    dcp->dump(cout);

}
















