#ifndef __GRAPH_H
#define __GRAPH_H

#include <iostream>
#include <map>
using namespace std;

#include "dist.h"

typedef map<int,float,less<int> > ADJMAP;


class GNode {
    public:
        int nadj;
        ADJMAP adj;    // list of adjacent nodes
        int label;                        // label
        
        GNode();
        ~GNode();
        bool isadj(int n);
        float getel(int n);
        void dump(ostream& outs);
};

class Graph {    // Adjacency list data structure
    public:
        int nnodes;
        GNode** nodelist;
        Graph();
        
        void asThresholdGraph(const DistMatrix& dm, float threshold);
        void dump(ostream& outs);    
        ~Graph();
        bool isadj(int x,int y);
        float edgelen(int x, int y);
        void makeadj(int x, int y, float el);
        bool connected();
        void make_clique(int n, int* nlist, float el);
};

/*****************************************************************
Depth-first search
Input: unrooted tree, starting node
Output: the depth-first traversal
*/

class GraphDFSIterator {  // Depth-First Search
    protected:
        const Graph* g;
        int* color;
        int currnode;
        int startnode;
        int* parlist;
        bool end_reached;

    public:
        GraphDFSIterator(const Graph* gin, int startnode);
	virtual ~GraphDFSIterator();
        bool at_end();
        int current();
        void next();
        void restart();
};    

#endif
