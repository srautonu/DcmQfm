
#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

#include <set>

using namespace std;


/*************************************************************************************

RTNode

*/



RTNode::RTNode() {
    parent=NULL;
    firstchild=NULL;
    sibl=NULL;
    upel=0.0;
    label=-1;
    utn=-1;
}    

    /* Print subtree rooted at node in newick format */
void RTNode::print_node(ostream& outs, const LABELMAP& lblmap) {
    if (firstchild==NULL) {outs << lblmap[label];}
    else {
        outs << "(";
        RTNode* i=firstchild;
        i->print_node(outs,lblmap);
        i=i->sibl;
        while(i!=NULL) {
            outs << ",";
            i->print_node(outs,lblmap);
            i=i->sibl;
        }    
        outs << ")";
    }
    outs << ":" << upel;
}
    
        /* Add child to this node */
void RTNode::addchild(RTNode* child) {
    if (firstchild!=NULL) {
        RTNode* ni=firstchild;
        while(ni->sibl!=NULL) {ni=ni->sibl;}
        ni->sibl=child;
    } else {
        firstchild=child;
    }   
    child->parent=this; 
}
    
        /* Delete the nodes in the subtree rooted at this node */
RTNode::~RTNode(void) {
    if (firstchild!=NULL) {
        RTNode* ni = firstchild;
        RTNode* lastn;
        while (ni!=NULL) {
            lastn=ni;
            ni=ni->sibl;
            delete lastn;
        }
    }
}

/*************************************************************************************

RootedTree

*/

        
RootedTree::RootedTree() {
    ntaxa=0;
    nnodes=0;
    root=NULL;
}

void RootedTree::print_rootedtree(ostream& outs, const LABELMAP& lblmap) {
    root->print_node(outs, lblmap);    
}

RootedTree::~RootedTree(void) {
    if (root) { delete root; }
}

/*************************************************************************************

RootedTreeParser

*/

/**
 * kliu - WARNING - responsibility of the caller to free the character array used to return the taxon name!
 */
char* RootedTreeParser::readlabel() {
  // kliu hardcoded constant - taxon names max 256 characters
    char sb[256];
    char* lbl;
    int cnt=0;
    // kliu peeling off the taxon name into array
    while(    (treestr[parser_head]>='0' && treestr[parser_head]<='9')
           || (treestr[parser_head]>='A' && treestr[parser_head]<='Z')
           || (treestr[parser_head]>='a' && treestr[parser_head]<='z')
           ||  treestr[parser_head]=='_' 
           ||  treestr[parser_head]=='-') {
        sb[cnt]=treestr[parser_head];
        cnt++;
        parser_head++;
        if (treestr[parser_head]==0) {break;}
        if (cnt>256) {
            printf("Error: label length > 256 at pos %d\n",parser_head);
            exit(1);
        }
    }
    // terminating null character
    sb[cnt] = '\0';
    cnt++;
    // kliu no associated free with this malloc() call
    lbl=(char*) malloc(sizeof(char)*cnt);
    strcpy(lbl,sb);
    return lbl;
}
        
        /* read an edge length */
float RootedTreeParser::readval () {
    char sb[256];
    float val;
    int cnt=0;
    while(    (treestr[parser_head]>='0' && treestr[parser_head]<='9')
           ||  treestr[parser_head]=='E' 
           ||  treestr[parser_head]=='e' 
           ||  treestr[parser_head]=='.' 
           ||  treestr[parser_head]=='+' 
           ||  treestr[parser_head]=='-') {
        sb[cnt]=treestr[parser_head];
        cnt++;
        parser_head++;
        if (treestr[parser_head]==0) {break;}
        if (cnt>256) {
            printf("Error: label length > 256 at pos %d\n",parser_head);
            exit(1);
        }
    }
    sb[cnt]=0;
    sscanf(sb,"%f",&val);
    return val;
}

/** 
   Parse a newick format 
   kliu WARNING - responsibility of caller to free the lblmap that's dynamically allocated here
*/
RootedTree* RootedTreeParser::parse_newick(const char* str, LABELMAP** lblmapv) {
    RTNode* tempnode=NULL;
    RTNode* currentnode=NULL;
    RTNode* currentparent=NULL;
    RTNode* currentlastsibl=NULL;
    RTNode* root=NULL;
    
    int headlast;
    int numnodes=0;
    int treestr_length;
    RootedTree* rt;

    LABELMAP* lblmap = new LABELMAP();
    *lblmapv=lblmap;
    set<string> labelset;

//    LBLLIST lblhead={NULL,NULL};    /* sentinel */
//    LBLLIST* lblptr=&lblhead;
    int numlabel=0;
    int i;

    treestr=str;

    parser_head=0;
    currentnode=NULL;
    treestr_length=strlen(str);

    while(parser_head<treestr_length) { 
        headlast=parser_head;
        if (treestr[parser_head]=='(') {                 /* New node */
            tempnode=new RTNode();  
            numnodes++;
            tempnode->upel=1.0;        
            if (root==NULL) {      /* This is root */
                root=tempnode;
                root->upel=0.0;
                currentparent=NULL;
            } else {
                if (treestr[parser_head-1]=='(') {    /* first child */
                    currentnode->addchild(tempnode);
                } else {                              /* child but not first */
                    currentparent->addchild(tempnode);
                }
                currentparent=currentnode;                /* new level */
            }
            currentnode=tempnode;
            parser_head++;
            continue;
        }
        if (treestr[parser_head]==')') {  // End list of children 
            if (currentnode==NULL) {
                /* Error: unbalanced node */
                return NULL;
            }
            currentnode=currentnode->parent;
            currentparent=currentnode->parent;
            parser_head++;
            continue;
        }
        if (treestr[parser_head]==':') {  // Starts edge length
            parser_head++;
            currentnode->upel=readval();
            continue;
        }
        if (treestr[parser_head]==';') {  // End of tree string 
            parser_head++;
            break;
        }
        if (treestr[parser_head]==',') {  // Next child 
            parser_head++;
            continue;
        }
        if ((    treestr[parser_head]>='A' && treestr[parser_head]<='Z') 
             || (treestr[parser_head]>='a' && treestr[parser_head]<='z')
             || (treestr[parser_head]>='0' && treestr[parser_head]<='9') 
             || (treestr[parser_head]=='_') 
             || (treestr[parser_head]=='-')) { /* a label  */
            tempnode=new RTNode(); 
            numnodes++;
            
//            lblptr->next=(LBLLIST*) malloc(sizeof(LBLLIST));
//            lblptr->next->next=NULL;
//            if (!lblptr->next) {printf("Error malloc in parse_newick()\n"); exit(1);}
//            lblptr=lblptr->next;
//            lblptr->lbl=readlabel();

	    
	    // leaking the character array used to pull the label
	    // best to just pass it in
	    char* labelString = readlabel();
            // kliu deep copy constructor for C++ STL string class
	    string lbl(labelString);
	    // free the character array!
	    free(labelString);
            

            if (labelset.find(lbl)!=labelset.end()) {
                cout << "Error: duplicate label " << lbl << endl;
                exit(1);
            }
            lblmap->push_back(lbl);
            tempnode->label=numlabel;
            numlabel++;
            
            if (headlast==0) {      /* One leaf */
                currentnode=tempnode;
                root=currentnode;
                continue;
            }
            
            if (treestr[headlast-1]=='(') {   /* first leaf */
                currentnode->addchild(tempnode);
                currentparent=currentnode;
            } else {
                currentparent->addchild(tempnode);
            }

            currentnode=tempnode;

            continue;
        }
        /* Error in parsing input */
        printf("Error: char %c at %d in the input tree",treestr[parser_head],parser_head);
        parser_head++;
    }
    rt=new RootedTree();
    rt->root=root;
    rt->ntaxa=numlabel;
    rt->nnodes=numnodes;
    i=0;
   
    return rt;
}

/*************************************************************************************

RTDFSIterator

*/

RTDFSIterator::RTDFSIterator(RootedTree* rtin) {
    rt=rtin;
    stack = NULL;
    restart();
}
bool RTDFSIterator::at_end() {return (stackptr==-1);}  //        at_end to indicate when there are no more objects to be examined.


RTNode* RTDFSIterator::current() {                     //        current to return the current object in the container.
    return stack[stackptr];
}    
void RTDFSIterator::next() {                           //        next to advance the iterator to the next object in the container.
    RTNode* nt; 
    nt=stack[stackptr];    // Pop
    stackptr--;
    if (nt->firstchild!=NULL) {  // Push all children
        RTNode* ni=nt->firstchild;
        while(ni!=NULL) {
            stackptr++;
            stack[stackptr]=ni;
            ni=ni->sibl;
        }
    }
}    
// each restart will dynamically allocate a new stack
// need to free previous stack
void RTDFSIterator::restart() {                       //        restart to reset the iterator to the first object in the container.
  if (stack != NULL) {
    delete (stack);
    stack = NULL;
  }
    stack=new RTNode*[rt->nnodes];
    stack[0]=rt->root;
    stackptr=0;
}    

RTDFSIterator::~RTDFSIterator() {
  if (stack != NULL) {
    delete stack;
    stack = NULL;
  }
}    

/*************************************************************************************

UTNode

*/

UTNode::UTNode(int numadj) {
    nadj=numadj;
    adj=new int[nadj]; 
    el=new float[nadj];
    label=-1;
}
        
UTNode::~UTNode() {
    delete adj;
    delete el;
}
        

        
float UTNode::getel(int n) {
    int i;
    for (i=0;i<nadj;i++) { if (adj[i]==n) return el[i];}
    return -1;       // Not adjacent
}
        
void UTNode::dump(ostream& outs, const LABELMAP& lblmap) {
    int i;
    outs << "Node " << this << " nadj:" << nadj << " label: " << lblmap[label] << endl;
    for (i=0;i<nadj;i++) {
        outs << "    " << adj[i] << " " << el[i] << endl;
    }
} 

/*************************************************************************************

UnrootedTree

*/

UnrootedTree::UnrootedTree(RootedTree* rt) {    // Convert a RootedTree instance to an UnrootedTree instance
    RTDFSIterator dfsi(rt);
    RTNode* curr;
    
    ntaxa=rt->ntaxa;
    
    // Create the nodes
    
    nnodes=rt->nnodes;
    nodelist=new UTNode*[nnodes];
    
    int cnt=0;
    
    while(! dfsi.at_end()){
        curr=dfsi.current();
        dfsi.next();
        // Count the number of adjacent nodes
        int i;
        if (curr->parent==NULL) {i=0;}
        else {i=1;}
        RTNode* ni;
        ni=curr->firstchild;
        while (ni!=NULL) {
            ni=ni->sibl;
            i=i+1;
        }
        nodelist[cnt]=new UTNode(i);
        curr->utn=cnt;
        nodelist[cnt]->label=curr->label;
        cnt++;
    }
    // Add adjacency
    dfsi.restart();
    
    while(! dfsi.at_end()){
        curr=dfsi.current();
        dfsi.next();
        // Count the number of adjacent nodes
        int i=0;
        UTNode* currutn=nodelist[curr->utn];
        if (curr->parent!=NULL) {
            currutn->adj[i]=curr->parent->utn;
            currutn->el[i]=curr->upel;
            i++;
        }
        RTNode* n=curr->firstchild;
        while(n!=NULL) {
            currutn->adj[i]=n->utn;
            currutn->el[i]=n->upel;
            n=n->sibl;
            i++;
        }
    }
    // Suppress root if root has degree 2
    UTNode* root=nodelist[0];
    startnode=0;
    if (root->nadj==2) {
        int x1=root->adj[0];
        int x2=root->adj[1];
        float elen=root->el[0]+root->el[1];
        // Root must be at the first pos in the adj list in x1 and x2
        nodelist[x1]->adj[0]=x2;
        nodelist[x1]->el[0]=elen;
        nodelist[x2]->adj[0]=x1;
        nodelist[x2]->el[0]=elen;
	// free it all at once during destructor
        //delete root;
        //nodelist[0]=NULL;
        startnode=x1;
    }
}

float UnrootedTree::edgelen(int x, int y) const {
    int i;
    UTNode* nx=nodelist[x];
    UTNode* ny=nodelist[y];
    
    if (nx->nadj<ny->nadj) {
        for (i=0;i<nx->nadj;i++) {
            if (nx->adj[i]==y) {break;}
        }    
        return nx->el[i];
    } else {
        for (i=0;i<ny->nadj;i++) {
            if (ny->adj[i]==x) {break;}
        }    
	

        return ny->el[i];
    }    
}    

int* UnrootedTree::findMedianEdge() const {   
    // Do a DFS, find the cluster sizes
    UTDFSIterator it(this,startnode);
    int clusize[nnodes];
    int v;
    while(! it.at_end()) {
        v=it.current();
        UTNode* vn=nodelist[v];
        if (vn->nadj==1) {
            clusize[v]=1;
        } else {
            int cv=0;
            for (int i=1;i<vn->nadj;i++) {
                cv=cv+clusize[vn->adj[i]];
            }
//            cout << v << " " << cv << endl;
            clusize[v]=cv;
        }    
        it.next();
    }
    
    // Find median node
    
    int i;
    if (startnode==0) {i=0;} else {i=1;}
    int bestv=i;
    int diff= 2*clusize[bestv]>nnodes ? 2*clusize[bestv]-ntaxa : ntaxa-2*clusize[bestv];  // abs(2*clusize[bestv] - nnodes)
    for (int j=i;j<nnodes;j++) {
        int d=2*clusize[j]>ntaxa ? 2*clusize[j]-ntaxa : ntaxa-2*clusize[j];
        if (d<diff) {bestv=j;}
    }
    // Find the edge
    int* edge=new int[2];
    edge[0]=bestv;
    edge[1]=nodelist[bestv]->adj[0];
    
//    cout << "Median edge: (" << edge[0] << "," << edge[1] << "), balance: " << clusize[bestv] <<  " out of " << ntaxa << endl;
    return edge;
}    


void UnrootedTree::dump(ostream& outs, const LABELMAP& lblmap) {
    int i;
    for (i=0;i<nnodes;i++) {
        if (nodelist[i]==NULL) {continue;}
        cout << "#" << i << " ";
        nodelist[i]->dump(outs, lblmap);
    }    
}

UnrootedTree::~UnrootedTree(){
    for (int i=0;i<nnodes;i++) {delete nodelist[i];}

    // also need to free array of node pointers
    if (nodelist != NULL) { 
      delete (nodelist);
      nodelist = NULL;
    }
}    

// Parser for Unrooted Tree; a wrap function 
/**
 * kliu WARNING - responsibility of caller to delete the lblmap that's dynamically allocated in here
 * kliu WARNING - responsibility of caller to delete the UnrootedTree object that's returned from this function
 */
UnrootedTree* UnrootedTreeParser::parse_newick(const char* str, LABELMAP** lblmapv){
    RootedTreeParser rtp;

    RootedTree* rt=rtp.parse_newick(str, lblmapv);
    UnrootedTree* ut=new UnrootedTree(rt); 
    delete rt;
    return ut;
}

/*************************************************************************************

UTEuclideanTourIterator

*/

UTEuclideanTourIterator::UTEuclideanTourIterator(const UnrootedTree* utin) {
    ut=utin;
    restart();
}
bool UTEuclideanTourIterator::at_end() {                         //        at_end to indicate when there are no more objects to be examined.
    return (edge[0]==-1 && edge[1]==-1);
}
int* UTEuclideanTourIterator::current() {                        //        current to return the current object in the container.
    return edge;
}    
void UTEuclideanTourIterator::next() {                           //        next to advance the iterator to the next object in the container.
    UTNode* u=ut->nodelist[edge[0]];
    UTNode* v=ut->nodelist[edge[1]];
    
    if (edge[1]==startnode && edge[0]==endnode) {
    //                cout << "Error: calling next() beyond the Euclidean Tour" << endl;
        edge[0]=-1;
        edge[1]=-1;
        return;
    }    

    int uidx=edge[0];
    edge[0]=edge[1];                               // It's a tour; the next edge visit must start from the end node of this visit
    if (uidx==v->adj[0]) {                            // u is "parent" of v; Downwards
        if (v->nadj==1) {                          // Leaf
            edge[1]=uidx;                          // Go back
            //                    cout << "Leaf: go back" << endl;
            return;
        } else {                                   // Keep going down
            edge[1]=v->adj[1];
            //                    cout << "Keep going down" << endl;
            return;
        }    
    } else {                                       // Upwards
        int i;                                     // Find the next node to visit
        
        for (i=1;i<v->nadj-1;i++) { 
            if (uidx==v->adj[i]) {
                edge[1]=v->adj[i+1];
                //                        cout << "Next subtree" << endl;
                return;
            }    
        }
        edge[1]=v->adj[0];                     // Further backtrack
        //                cout << "Go back" << endl;
        return;
    }    
}    
void UTEuclideanTourIterator::restart() {                       //        restart to reset the iterator to the first object in the container.
    startnode=ut->startnode;
    UTNode* startn=ut->nodelist[startnode];
    endnode=startn->adj[startn->nadj-1];
    
    edge[0]=startnode;
    edge[1]=ut->nodelist[startnode]->adj[0];
}


/***********************************************
UTDFSIterator

Uses the LRC algorithm (white-gray-black); return a node when it turns black
*/

UTDFSIterator::UTDFSIterator(const UnrootedTree* utin, int startnodein) { 
    ut=utin; 
    startnode=startnodein;
    color=new int[ ut->nnodes ];
    parlist=new int[ ut->nnodes ];
    restart(); 
}

inline bool UTDFSIterator::at_end(){
    return end_reached;
}

int UTDFSIterator::current(){
    return currnode;
}

void UTDFSIterator::next(){
    if (color[startnode]==2) {end_reached=true; return;}
    
    // Backtrack; find the most recent ancestor that is not black
    while(color[currnode]==2) {currnode=parlist[currnode];}

    while(true) {    // Keep dfs until a new black node appears
        int nadj=ut->nodelist[currnode]->nadj;
        
        int* adjlist=ut->nodelist[currnode]->adj;
        
        int i;
        bool find_a_white_flag=false;
        
        int ai=0;
        while(ai<nadj) {   // Try finding the next white node
            int v=adjlist[ai];
            if (color[v]==0) {      // A white node; set up parent-child relation and traverse deeper
                color[v]=1;
//                cout << "Gray: " << v ;
                parlist[v]=currnode;
//                cout << "parent: " << currnode << endl;
                currnode=v;
                find_a_white_flag=true;
                break;
            }
            ai++;
        }
        if (find_a_white_flag) {continue;}

        color[currnode]=2;  // Black
        break;
    }    
}

void UTDFSIterator::restart() {
    int i;
    for (i=0;i<ut->nnodes;i++) {color[i]=0;parlist[i]=0;}
    currnode=startnode;
    color[startnode]=1;     // Gray
    parlist[startnode]=-1;  // No parent
    end_reached=false;
    next();
}


/***********************************************
UTEdgeIterator
*/

UTEdgeIterator::UTEdgeIterator(const UnrootedTree* utin){
    ut=utin;
    UTEuclideanTourIterator* uteti=new UTEuclideanTourIterator(ut);
    restart();
}

UTEdgeIterator::~UTEdgeIterator(){
    delete uteti;
}

bool UTEdgeIterator::at_end(){
    return uteti->at_end();
}
    
const int* UTEdgeIterator::current(){
    return uteti->current();
}
    
void UTEdgeIterator::next(){
    while(true) {
        uteti->next();
        int* edge=uteti->current();
        if (edge[0] < edge[1]) { break;}  // Only returns one of the two visits
    }
}
    
void UTEdgeIterator::restart(){
    uteti->restart();
    int* edge=uteti->current();
    if (edge[0] > edge[1]) {next();}
}    




