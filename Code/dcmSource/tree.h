#ifndef __TREE_H
#define __TREE_H

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <string.h>

using namespace std;


/*************************************************************************************

Input handling

read_distmatrix
parse_newick
unroot_tree

*/


typedef vector<string> LABELMAP;

class RTNode {
    public:
        RTNode* parent;                        /* parent node */
        RTNode* firstchild;                    /* first child */
        RTNode* sibl;                          /* sibling linked list */
        float upel;                            /* up-edge length */
        int label;                             /* label; -1 if not a leaf */
        int utn;                               /* for un-root conversion */

        RTNode();

    /* Print subtree rooted at node in newick format */
        void print_node(ostream& outs, const LABELMAP& lblmap);
    
        /* Add child to this node */
        void addchild(RTNode* child);
        /* Delete the nodes in the subtree rooted at this node */
        ~RTNode(void);
};

/* Linked list for labels */
typedef struct _lbllist {
    char* lbl;
    struct _lbllist* next;
} LBLLIST;

class RootedTree {
    public:
        int ntaxa;
        int nnodes;
        RTNode* root;
        
        RootedTree();
        void print_rootedtree(ostream& outs, const LABELMAP& lblmap);
        ~RootedTree(void);
};

// kliu this parser code needs to be cleaned up
// lots of hardcoded constants, permissible characters also hardcoded...
class RootedTreeParser {
    int parser_head;
    const char* treestr;

    private:
        char* readlabel();
        float readval ();
    public:
    /* Parse a newick format */
        RootedTree* parse_newick(const char* string, LABELMAP** lblmapv);
};

class RTDFSIterator {       // Depth-First Search iterator for rooted tree
    private:
        RootedTree* rt;
        RTNode** stack;
        int stackptr;

    public:
        RTDFSIterator(RootedTree* rtin);
        bool at_end();
        RTNode* current();
        void next();
        void restart();
        ~RTDFSIterator();        
};


class UTNode {
    public:
        int nadj;
        int* adj;    // list of adjacent nodes
        float* el;   // list of edge lengths
        int label;   // label
        
        UTNode(int numadj);
        ~UTNode();
        float getel(int n);
        void dump(ostream& outs, const LABELMAP& lblmap);
};

class UnrootedTree {
    public:
        int ntaxa;
        int nnodes;
        int startnode;          // For Eulerian Tour Iteration
        UTNode** nodelist;
        UnrootedTree(RootedTree* rt);
        ~UnrootedTree();
        int* findMedianEdge() const;
        float edgelen(int x, int y) const;
        void dump(ostream& outs, const LABELMAP& lblmap);
};

class UnrootedTreeParser {
    public:
    /* Parse a newick format */
        UnrootedTree* parse_newick(const char* string, LABELMAP** lblmapv);
};

// not euclidean tour, Eulerian tour?

class UTEuclideanTourIterator {                   
    private:
        const UnrootedTree* ut;
        int edge[2];
        int startnode;
        int endnode;

    public:
        UTEuclideanTourIterator(const UnrootedTree* utin);
        bool at_end();
        int* current();
        void next();
        void restart();
};


/*UTDFSIterator

Uses the LRC algorithm (white-gray-black); return a node when it turns black
*/

class UTDFSIterator {      // Depth-First Search iterator for unrooted tree
    protected:
        const UnrootedTree* ut;
        int* color;
        int currnode;
        int startnode;
        int* parlist;
        bool end_reached;

    public:
        UTDFSIterator(const UnrootedTree* utin, int startnode);
        bool at_end();
        int current();
        void next();
        void restart();
};

/*UTEdgeIterator

Iterate over all edges

*/

class UTEdgeIterator {      // Edge iterator for unrooted tree
    // Uses Eulerian Tour, but only output edges from smaller indexed node to larger
    //   That is, edge[0] < edge[1]
    protected:
        const UnrootedTree* ut;
        UTEuclideanTourIterator* uteti;

    public:
        UTEdgeIterator(const UnrootedTree* utin);
        ~UTEdgeIterator();
        bool at_end();
        const int* current();
        void next();
        void restart();
};


#endif






