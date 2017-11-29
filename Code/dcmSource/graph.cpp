/**************************

Graph algorithms for DCM

*/


#include <iostream>
#include "stdio.h"
#include "stdlib.h"

using namespace std;

#include "graph.h"

/***********************************************
GNode
*/

GNode::GNode() {}
        
GNode::~GNode() {}
        
bool GNode::isadj(int n) {
    return (adj.find(n)!=adj.end()) ;
}
        
float GNode::getel(int n) {
    int i;
    if (adj.find(n)==adj.end()) {
        return -1;       // Not adjacent
    } else {
        return adj[n];
    }    
}
        
void GNode::dump(ostream& outs) {
    int i;
    outs << "Node " << this << " nadj:" << nadj << " label: " << label << endl;
    ADJMAP::iterator ai=adj.begin();
    while(ai!=adj.end()) {
        outs << "    " << ai->first << " " << ai->second << endl;
        ai++;
    }
}    
    
/***********************************************
Graph
*/

Graph::Graph() { nodelist=NULL; nnodes=0;}

void Graph::asThresholdGraph(const DistMatrix& dm, float threshold) {
    nnodes=dm.ntaxa;
    nodelist=new GNode*[nnodes];
    int i,j;
    float** distm;
    distm=dm.D;
    for (i=0;i<nnodes;i++) {
        int cnt=0;
        nodelist[i]=new GNode();
        nodelist[i]->label=i;
        cnt=0;
        for (j=0;j<nnodes;j++) {   // Add adjacency
            if (j==i) {continue;}
            if (distm[i][j]<=threshold) {
                nodelist[i]->adj[j]=distm[i][j];
                cnt++;
            }
        }
        nodelist[i]->nadj=nodelist[i]->adj.size();
    }
}    

void Graph::dump(ostream& outs){
    int i;
    for (i=0;i<nnodes;i++) {
        if (nodelist[i]==NULL) {continue;}
        cout << "#" << i << " ";
        nodelist[i]->dump(outs);
    } 
}

Graph::~Graph() {
    int i;
    for (i=0;i<nnodes;i++) {
        delete nodelist[i];
    }
    delete nodelist;
}

bool Graph::isadj(int x,int y){
    int i;
    
    if (x==y) {return false;}
    GNode* nx=nodelist[x];
    GNode* ny=nodelist[y];
    if (nx->nadj<ny->nadj) {
        return nx->isadj(y);
    } else {
        return ny->isadj(x);
    }        
}    

void Graph::make_clique(int n, int* nlist, float el) {
    for (int i=0;i<n;i++) {
        for (int j=i+1;j<n;j++) {
            makeadj(nlist[i],nlist[j],el);
        }
    }        
}    

float Graph::edgelen(int x, int y) {
    int i;
    GNode* nx=nodelist[x];
    GNode* ny=nodelist[y];
    if (nx->nadj<ny->nadj) {
        for (i=0;i<nx->nadj;i++) {
            if (nx->adj.find(y)!=nx->adj.end()) {return nx->adj[y];}
        }    
    } else {
        for (i=0;i<ny->nadj;i++) {
            if (ny->adj.find(x)!=ny->adj.end()) {return ny->adj[x];}
        }    
    }        
    return INFDIST;
}

void Graph::makeadj(int x, int y, float el) {
    if (x==y) {return;}
    nodelist[x]->adj[y]=el;
    nodelist[y]->adj[x]=el;
}    

bool Graph::connected(){
    GraphDFSIterator gi(this,0);
    int j=0;
    while(! gi.at_end()) {
        j++;
        gi.next();
    }

    if (j!=nnodes) {return false;}
    return true;
}

/***********************************************
GraphDFSIterator

Uses the LRC algorithm (white-gray-black); return a node when it turns black
*/

GraphDFSIterator::GraphDFSIterator(const Graph* gin, int startnodein) { 
    g=gin; 
    startnode=startnodein;
    color=new int[ g->nnodes ];
    parlist=new int[ g->nnodes ];
    restart(); 
}

// why are there so many objects that just perform DFS???
GraphDFSIterator::~GraphDFSIterator() {
  delete (color);
  delete (parlist);
}

bool GraphDFSIterator::at_end(){
    return (end_reached);
}

int GraphDFSIterator::current(){
    return currnode;
}

void GraphDFSIterator::next(){
    if (color[startnode]==2) {end_reached=true; return;}
    
    // Backtrack; find the most recent ancestor that is not black
//    cout << currnode << endl;
    while(color[currnode]==2) {currnode=parlist[currnode];}

    while(true) {    // Keep dfs until a new black node appears
        int nadj=g->nodelist[currnode]->nadj;
        ADJMAP adjlist=g->nodelist[currnode]->adj;
        int i;
        bool find_a_white_flag=false;
        
//        cout << "Try finding white node, starting with " << currnode << ":" << endl;
//        cout << "    adj list: ";
        
//      for (i=0;i<nadj;i++) { cout << adjlist[i] << " ";}
//        cout << endl;
        ADJMAP::iterator ai=adjlist.begin();
        while(ai!=adjlist.end()) {   // Try finding the next white node
            int v=(*ai).first;
//            cout << "    try " << v << " color: " << color[v] << endl;
            if (color[v]==0) {      // A white node; set up parent-child relation and traverse deeper
                color[v]=1;
                parlist[v]=currnode;
                currnode=v;
                find_a_white_flag=true;
                break;
            }
            ai++;
        }
        if (find_a_white_flag) {continue;}
        // Currnode has exhausted all its adjacent white nodes; trace back
//        cout << "    Traceback " << currnode << endl;

        color[currnode]=2;  // Black
        break;
    }
}

void GraphDFSIterator::restart() {
    int i;
    for (i=0;i<g->nnodes;i++) {color[i]=0;parlist[i]=0;}
    currnode=startnode;
    color[startnode]=1;    // Gray
    parlist[startnode]=-1;  // No parent
    end_reached=false;
    next();
}





