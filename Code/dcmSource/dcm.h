#ifndef __DCM_H
#define __DCM_H

#include <iostream>
#include <stdio.h>
#include <stdlib.h>

using namespace std;

#include "dist.h"
#include "graph.h"

#include "tree.h"

#include <set>

typedef set<int, less<int> > SETINT;


// Perfect elimination ordering

class PEO {
    public:
  // with dynamic allocation of order array below,
  // not good form to omit constructor/destructor
  PEO();
  virtual ~PEO();
        int nnodes;
        int* order;
        void dump(ostream& outs) const ;
};

// List of nodes as a subproblem in a decomposition
class DecompSubProblem {
    public:
        int nnodes;
        int* nodelist;
        DecompSubProblem* next;
        
        DecompSubProblem(int n);
        DecompSubProblem(const DecompSubProblem& dsp);
        ~DecompSubProblem();
        void dump(ostream& outs, const LABELMAP& lblmap) const;
        void translate(const UnrootedTree* ut);  // Translate node indices to node labels
};

// A decomposition, as a linked list of subproblems
class Decomp {
    public:
        DecompSubProblem* head;
        DecompSubProblem* tail;
        Decomp();
        Decomp(const Decomp& dcp);
        void addSubproblem(DecompSubProblem* in);
        void dump(ostream& outs, const LABELMAP& lblmap) const;
        ~Decomp();
        void translate(const UnrootedTree* ut);  // Translate node indices to node labels
};    



/*************************************************************************************

Basic algorithms 

Threshold graph
Input: distance matrix, threshold
Output: weighted threshold graph
Data structure: adjacency distance matrix (-inf means not adjacent!)

Greedy triangulation heuristic
Input: weighted threshold graph in adjacency distance matrix
Output: triangulated adjacency distance matrix, perfect elimination ordering

Perfect elimination ordering
Input: weighted threshold graph in adjacency distance matrix
Output: perfect elimination ordering

Enumeration of maximal cliques in a triangulated graph
Input: weighted threshold graph in adjacency distance matrix, perfect elimination ordering
Output: an iterator of the list of maximal cliques

Minimal vertex separator
Input: weighted threshold graph in adjacency distance matrix, list of maximal cliques
Output: a maximal clique separator with minimal weight

Decomposition with minimal vertex separator
Input: weighted threshold graph in adjacency distance matrix, minimal vertex separator
Output: DCM-2 style decomposition

Padded short subtree graph
Input: unrooted edge weighted tree, padding constant $p$
Output: $p$-padded short subtree graph

Median edge
Input: unrooted tree
Output: a median edge that has the most balanced partition

Depth-first search
Input: unrooted tree, starting node
Output: the depth-first traversal

*/


class DCMGraph: public Graph {
    public:
        float dcm1TriangulateCost(SETINT& Vprime, int v);
        PEO* GreedyTriangulate();
        DecompSubProblem* MinVertexSeparator(const Decomp& dc);
        Decomp* DecomposebyMinVertexSeparator(const DecompSubProblem& sep);
        Decomp* EnumerateMaxCliques(const PEO* peoin);
        PEO* PerfectEliminationOrdering();
};

class PaddedShortSubtreeGraph: public DCMGraph {
    public:
        PaddedShortSubtreeGraph(const UnrootedTree* ut, int p);
};

class AdaptivePaddedShortSubtreeGraph: public DCMGraph {
    public:
        AdaptivePaddedShortSubtreeGraph(const UnrootedTree* ut, int maxprobsize);
};

class DCM2ComponentFinder: public GraphDFSIterator {  // Depth-First Search, excluding the vertex separator
    public:
        DCM2ComponentFinder(const Graph* gin): GraphDFSIterator(gin, 0) {};
        void loadSeparator(const DecompSubProblem& separator);
        Decomp* components();
};

class PaddedSubtreeGraphFinder {  // Depth-First Search, excluding the vertex separator
    public:
        const UnrootedTree* ut;
        PaddedSubtreeGraphFinder(const UnrootedTree* utin);
        Decomp** paddedSubTree(const int* edge, int p, bool pass_clusters);
    //  Do DFS for each of the subtrees; compute the distance to the roots of the subtrees for each subtree
    //  Returns an array of size two
    //  First: clusters of padded short subtree
    //  Second: NULL if pass_clusters=false
    //          the clusters of each of the subtrees excluding those in the short subtree if pass_clusters=true

};


/******************************************************
   DFS iterator for padded short subtree computation
*/

class PaddedShortSubtreeDFSIterator {      // Depth-First Search iterator for unrooted tree
    protected:
        const UnrootedTree* ut;
        int* parent;
        int startnode;
        int* stack;
        int stackptr;

    public:
        PaddedShortSubtreeDFSIterator(const UnrootedTree* utin, const int* edge);
        virtual ~PaddedShortSubtreeDFSIterator();
        bool at_end_subtree();
        int current();
        void next();
        void start_subtree(int subtreeroot);
        void restart(const int* edge);

    friend class PaddedSubtreeGraphFinder;
};

/*************************************************************************************

Top-level algorithms 

DCM-1
DCM-2
DCM-3
DCM-4
Median edge decomposition

*/

/*************************************************************************************
DCM-1
*/

class DCM1_Factory {
    public:
        Decomp* decompose(const DistMatrix& dm, float threshold);
};

/*************************************************************************************
DCM-2
*/

class DCM2_Factory {
    public:
        Decomp* decompose(const DistMatrix& dm, float threshold);
};

/*************************************************************************************
DCM-3
*/

class DCM3_Factory {
    public:
        Decomp* decompose(const UnrootedTree* ut, int p);
};

/*************************************************************************************
Median edge decomposition
*/

class MEDecomp_Factory {
    public:
        Decomp* decompose(const UnrootedTree* ut, int p);
};


/*************************************************************************************
DCM-4
*/

class DCM4_Factory {
    public:
        Decomp* decompose(const UnrootedTree* ut, int p);
};

/*************************************************************************************
Adaptive DCM-4
*/

class AdaptiveDCM4_Factory {
    public:
        Decomp* decompose(const UnrootedTree* ut, int p);
};


#endif
