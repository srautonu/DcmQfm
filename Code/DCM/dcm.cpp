
#include <stdio.h>
#include <stdlib.h>

#include "dcm.h"



/*************************************************************************

Perfect Elimination Ordering
Decomposition 

*/

PEO::PEO () {
  nnodes=0;
  order = NULL;
}

PEO::~PEO () {
  if (order != NULL) { 
    delete(order);
    order = NULL;
  }
}

void PEO::dump(ostream& outs) const {
    for (int i=0;i<nnodes;i++) {outs << order[i] << " ";}
    outs << endl;
}

DecompSubProblem::DecompSubProblem(int n) {nnodes=n; nodelist=new int[n]; next=NULL;}

DecompSubProblem::~DecompSubProblem() {delete nodelist;}     

void DecompSubProblem::dump(ostream& outs, const LABELMAP& lblmap) const {
    for (int i=0;i<nnodes;i++) {
        outs << lblmap[nodelist[i]] << " ";
    }
}

void DecompSubProblem::translate(const UnrootedTree* ut) {
    for (int i=0;i<nnodes;i++) {nodelist[i]=ut->nodelist[nodelist[i]]->label;}
}

DecompSubProblem::DecompSubProblem(const DecompSubProblem& dsp) {
    nnodes=dsp.nnodes; nodelist=new int[nnodes]; next=NULL;
    for (int i=0;i<nnodes;i++) {nodelist[i]=dsp.nodelist[i];}
}    

Decomp::Decomp(){ head=NULL; tail=NULL;} 

Decomp::Decomp(const Decomp& dcp) { 
    head=NULL; tail=NULL;
    DecompSubProblem* h=dcp.head;
    while(h!=NULL) {
        DecompSubProblem* dsp=new DecompSubProblem(*h);
        addSubproblem(dsp);
        h=h->next;
    }
} 


void Decomp::addSubproblem(DecompSubProblem* in) {
    if (head==NULL) {head=in; tail=in;}
    else {
        tail->next=in;
        tail=in;
    }
}

void Decomp::translate(const UnrootedTree* ut) {
    DecompSubProblem* h=head;
    while(h!=NULL) {h->translate(ut); h=h->next;}
} 

void Decomp::dump(ostream& outs, const LABELMAP& lblmap) const {
    DecompSubProblem* h=head;
    while(h!=NULL) {
        outs << "* ";
        h->dump(outs, lblmap);
        outs << endl;
        h=h->next;
    }    
}
    
Decomp::~Decomp(){
    DecompSubProblem* h=head;
    while (h!=NULL) {
        h=head->next;
        delete head;
        head=h;
    }
}    

/*************************************************************************************

Basic algorithms 

Greedy triangulation heuristic
Input: weighted threshold graph
Output: triangulated adjacency distance matrix, perfect elimination ordering

Perfect elimination ordering
Input: threshold graph
Output: perfect elimination ordering

Enumeration of maximal cliques in a triangulated graph
Input: weighted threshold graph, perfect elimination ordering
Output: an iterator of the list of maximal cliques

Minimal vertex separator
Input: weighted threshold graph, list of maximal cliques
Output: a maximal clique separator with minimal weight

Decomposition with minimal vertex separator
Input: weighted threshold graph, minimal vertex separator
Output: DCM-2 style decomposition

Padded short subtree graph
Input: unrooted edge weighted tree, padding constant $p$
Output: $p$-padded short subtree graph

Median edge
Input: unrooted tree
Output: a median edge that has the most balanced partition

*/


/*************************************************************************************
DCM-1 Triangulation Cost 
*/

float DCMGraph::dcm1TriangulateCost(SETINT& Vprime, int v) {
    int i,j,u,w;
    int lvpc;
    float c_uw;
    float cost=-INFDIST;
    
    for (i=0;i<nnodes;i++) {
        if (Vprime.find(i)!=Vprime.end()) {continue;}   // u not in V'
        u=i;
        if (u==v){ continue;}
        if (! isadj(u,v)) {continue;}                   // (u,v) \in E
        for (j=i+1;j<nnodes;j++) {
            if (Vprime.find(j)!=Vprime.end()) {continue;} // w not in V'
            w=j;
            if (v==w) {continue;}
            if (! isadj(v,w)) {continue;}               // (v,w) \in E
            c_uw=edgelen(u,w);                          // cost(v)=d(u,w)
            if (c_uw > cost) {
                cost=c_uw;
            }}}
    return cost;
}

/*************************************************************************************
Greedy triangulation heuristic
*/

PEO* DCMGraph::GreedyTriangulate(){
    SETINT Vprime;
    int* neighbor;
    int i,j,vmin,v,u,w,neighborcnt; // VprimeC cardinality; number of neighbors
    float vmincost,vc;
    PEO* peo;
    int peocnt=0;
    
    peo=new PEO();
    peo->nnodes=nnodes;
    peo->order=new int[nnodes];
    
    neighbor=new int[nnodes]; /* number of neighbors of vertex v */

    while(Vprime.size() <= nnodes-2){
        /* find smallest cost vertex v */
//        cout << "Vprime.size = " << Vprime.size() << ", nnodes = " << nnodes << endl;
        vmin=-1;
        vmincost=INFDIST;
        for (i=0;i<nnodes;i++) {
            if (Vprime.find(i)!=Vprime.end()) {continue;}  // v not in V'
            v=i;
            vc=dcm1TriangulateCost(Vprime,v);
//            cout << v << " " << vc << "; " ;
            if (vmincost>vc){
                vmincost=vc;
                vmin=v;
            }
        }
//        cout << endl;
        Vprime.insert(vmin);

        /* make the neighbor of v into a clique */

        peo->order[peocnt]=vmin;
        peocnt++;
//        cout << "Make clique for neighbors of node " << vmin << endl;

        neighborcnt=0;
        
        GNode* nv=nodelist[vmin];
//        cout << nv << endl;
        ADJMAP::iterator ai=nv->adj.begin();
        while(ai!=nv->adj.end()) {
            int d=ai->first;
            ai++;
            if (Vprime.find(d)!=Vprime.end() ) { continue;};
            neighbor[neighborcnt]=d;
//            cout << d << " ";
            neighborcnt++;
        }    
//        cout << endl;

        for (i=0;i<neighborcnt;i++) {
            for (j=i+1;j<neighborcnt;j++) {
//                cout << "(" << neighbor[i] << "," << neighbor[j] << ")";
                makeadj(neighbor[i],neighbor[j],1.0);
            }
        }
//        cout << endl;
    }

    delete neighbor; /* number of neighbors of vertex v */
    
    for (i=0;i<nnodes;i++) {
        if (Vprime.find(i)==Vprime.end()) {         /* append the last vertices to sigma */
            peo->order[peocnt]=i;
            peocnt++;
        }
    }
    
    return peo;
}    


/*************************************************************************************
Perfect elimination ordering
*/


PEO* DCMGraph::PerfectEliminationOrdering() {
    int* lbllist=new int[nnodes];
    int* number=new int[nnodes];
    PEO* peo=new PEO();
    peo->nnodes=nnodes;
    peo->order=new int[nnodes];
    int i,v,j;
    for (i=0;i<nnodes;i++) {lbllist[i]=0;number[i]=-1;}       // Line 1: assign label 0 to each vertex
    for (i=nnodes-1;i>=0;i--) {                               // Line 2: for i from n to 1 by -1 do
        int bestv=-1;
        for (v=0;v<nnodes;v++) {                              // Line 3:    Select: pick an unnumbered vertex v with largest label
//            cout << "   v=" << v << ", number=" <<  number[v] << ", label=" << lbllist[v] << endl;
            if (number[v]==-1) {    // Unnumbered
                if (bestv==-1) {
                    bestv=v;
                } else if (lbllist[v]>lbllist[bestv]) {
                    bestv=v;
                }
            }
        }
//        cout << "bestv=" << bestv << ", label of bestv= " << lbllist[bestv] << endl;
        peo->order[i]=bestv;                                  // Line 4: sigma(i) <- v
        number[bestv]=i;
        
        ADJMAP bestvnadj=nodelist[bestv]->adj;
        ADJMAP::iterator ai=bestvnadj.begin();
        while(ai!=bestvnadj.end()) {
            j=ai->first;
            if (number[j]==-1) {    // Unnumbered
                lbllist[j]=lbllist[j]+1;                      // Line 6: add 1 to label
            }    
            ai++;
        }    
    }
    delete lbllist;
    delete number;
    return peo;
}

/*************************************************************************************
Enumerate Maximal Cliques in a Triangulated Graph

kliu - WARNING - responsibility of caller to delete the resulting Decomp object
*/

Decomp* DCMGraph::EnumerateMaxCliques(const PEO* peoin){
    int i,j,u,v;
    int *peoinv, *X, *S;
    int* peo=peoin->order;
    DecompSubProblem* maxclique;
    Decomp* maxcliques;
    double vc;
    int vmin;
    float vmincost;
    int Xcnt=0,sXcnt=0,minsX=0,sigmainv_v,sigmainv_Xcnt,x,vneighbor,xv;
    int peocnt=peoin->nnodes;

    // kliu - construction is strange - causing valgrind errors on deletion
    maxcliques=new Decomp();
    
    S=new int[nnodes];
    X=new int[nnodes];
    peoinv=new int[nnodes];
    
    /* enumerate all max cliques according to 
       the perfect elimination ordering peo */
/*     
# From Shamir, "Advanced Topics in Graph Theory", Figure 6.2
#
# 1. chi <- 1
# 2. for all vertices v do S(v) <- 0
# 3. for i <- 1:n do
# 4.     v <- sigma(i)
# 5.     X <- { x \in Adj(v) | sigma^{-1}(v) < sigma^{-1}(x) }
# 6.     if Adj(v) = \emptyset: print {v}
# 7.     if X = \emptyset: goto 13
# 8.     u <- sigma( min{ sigma^{-1}(x) | x \in X})
# 9.     S(u) <- max{S(u), |X|-1}
# 10.    if S(v) < |X|:
# 11.        print {v} \cup X
# 12.        chi=max{chi, 1+|X|}
# 13. end
*/       
    for (i=0;i<peocnt;i++) {peoinv[peo[i]]=i;}    /* compute inverse of sigma */
    for (i=0;i<peocnt;i++) {S[i]=0;}              /* line 2 */
    for (i=0;i<peocnt;i++) {                      /* line 3 */
        v=peo[i];                                 /* line 4 */
        Xcnt=0;                                   /* line 5 */
        sigmainv_v=peoinv[v];
        for (x=0;x<peocnt;x++) {
            if (isadj(x,v)) {  // Adjacent
                if (sigmainv_v < peoinv[x]) {
                    X[Xcnt]=x;
                    Xcnt++; 
        }}}
        vneighbor=0;                 /* line 6 */
        for (j=0;j<peocnt;j++) {      /* Test if no other nodes are adjacent */
            if (isadj(v,j)) {
                vneighbor=1;
                break;  
        }}
        if (vneighbor==0) {
            maxclique=new DecompSubProblem(1);
            maxclique->nodelist[0]=v;
            maxcliques->addSubproblem(maxclique);
        }
        
        if (Xcnt==0) {break;}       /* line 7 */
        sigmainv_Xcnt=0;            /* line 8 */
        minsX=peocnt+1;
        for (j=0;j<Xcnt;j++) {
            if (minsX>peoinv[X[j]]) {
                minsX=peoinv[X[j]];
            }
        }
        u=peo[minsX];
        if (S[u]<Xcnt-1) {          /* line 9 */
            S[u]=Xcnt-1;
        }
        if (S[v]<Xcnt) {            /* line 10 */
            X[Xcnt]=v;
            Xcnt++;
            maxclique=new DecompSubProblem(Xcnt);
            for (j=0;j<Xcnt;j++) {
                maxclique->nodelist[j]=X[j];
            }
            maxcliques->addSubproblem(maxclique);   /* line 11 */
        }
    }
    delete S;
    delete X;
    delete peoinv;
    
    return maxcliques;
}

/*************************************************************************************
Finding components excluding a maximal clique
*/

void DCM2ComponentFinder::loadSeparator(const DecompSubProblem& separator){
    // Mark all nodes in the separator already visited (black)
    int i;
    for (i=0;i<g->nnodes;i++) {
        color[i]=0;
        parlist[i]=-1;
    }    
    for (i=0;i<separator.nnodes;i++) {
        color[separator.nodelist[i]]=2;
    }
}    

Decomp* DCM2ComponentFinder::components(){
    Decomp* dmp=new Decomp();
    int tmpnlist[g->nnodes];
    int ncnt;
    while(true) {
        // Find a starting node that is white
        int i;
        for (i=0;i<g->nnodes;i++) {
            if (color[i]!=2) {break;}
        }
//        cout << "i= " << i << endl;
        if (i==g->nnodes) {break;}
        // Restart
        startnode=i;
        currnode=startnode;
        color[startnode]=1;    // Gray
        parlist[startnode]=-1;  // No parent
        end_reached=false;
        next();
        
        ncnt=0;
//        cout << "j=" ;
        while(!at_end()) {
            int j=current();
//            cout  << j << " ";
            tmpnlist[ncnt]=j;
            ncnt++;
            next();
        }
//        cout << endl;
        // Create new subproblem (component)
        DecompSubProblem* dsp=new DecompSubProblem(ncnt);
        for (i=0;i<ncnt;i++) {dsp->nodelist[i]=tmpnlist[i];}
//        cout << "dsp:";
//      dsp->dump(cout);
//        cout << endl;
        dmp->addSubproblem(dsp);
    }
    return dmp;
}

/*************************************************************************************
Minimal vertex separator

just picks out max clique which is a separator that minimizes the maximum size of remaining connected components

kliu WARNING - responsibility of caller to delete the returned DecompSubProblem object!
*/

DecompSubProblem* DCMGraph::MinVertexSeparator(const Decomp& maxcliques){
    /*Compute a vertex separator X in G(d, q) such that X is a maximal
    clique and max_i |X U Ai| is minimized where A1,A2, . . . ,Ar are the
    connected components of the graph G(d, q) - X (see Figure 2.10).
    The set {X U A1, . . . ,X U Ar} will form the DCM2 subproblems.
    Note that since G(d, q) is triangulated, we can compute all the
    clique separators in polynomial time.
    */
    DecompSubProblem* maxclique= maxcliques.head, *bestsep;
    DCM2ComponentFinder cf(this);
    Decomp* componentlist;
    
    int bestscore=nnodes*2;
    while(maxclique!=NULL) {
        int sepsize=maxclique->nnodes;
        int maxsubprobsize=0;
        cf.loadSeparator(*maxclique);
        componentlist=cf.components();
        // Compute |X U Ai| for each Ai in componentlist
        DecompSubProblem* component=componentlist->head;
        while(component!=NULL) {
            int ss=sepsize+component->nnodes;
            if (ss>maxsubprobsize) {maxsubprobsize=ss;}
            component=component->next;
        }
        if (bestscore>maxsubprobsize) {
            bestscore=maxsubprobsize;
            bestsep=maxclique;
        }
        maxclique=maxclique->next;
        delete componentlist;
    }
    return bestsep;
}

Decomp* DCMGraph::DecomposebyMinVertexSeparator(const DecompSubProblem& sep){
    Decomp* dcp= new Decomp();
    
    if (sep.nnodes==this->nnodes) {  // Separator = graph
        DecompSubProblem* dsp=new DecompSubProblem(sep.nnodes);
        for (int i=0;i<sep.nnodes;i++) {dsp->nodelist[i]=sep.nodelist[i];}
        dcp->addSubproblem(dsp);
        return dcp;
    }    
    
    DCM2ComponentFinder cf(this);

    cf.loadSeparator(sep);
    Decomp* componentlist=cf.components();
    // Compute X U Ai for each Ai in componentlist
    int sepsize=sep.nnodes;
    DecompSubProblem* component=componentlist->head;
    while(component!=NULL) {
        int i;
        DecompSubProblem* dsp=new DecompSubProblem(sepsize+component->nnodes);
        for (i=0;i<sepsize;i++) {dsp->nodelist[i]=sep.nodelist[i];}
        for (i=0;i<component->nnodes;i++) {dsp->nodelist[i+sepsize]=component->nodelist[i];}
        dcp->addSubproblem(dsp);
        component=component->next;
    }
    delete componentlist;
    return dcp;    
} 


/******************************************************
   DFS iterator for padded short subtree computation
   Use preorder computation instead!
*/

// eh? no cleanup for this???
// kliu - this memory is being leaked! 
// eh? no cleanup for this???
PaddedShortSubtreeDFSIterator::PaddedShortSubtreeDFSIterator(const UnrootedTree* utin, const int* edge) {
    ut=utin;
    parent=new int[ ut->nnodes ];  // parent[v]=-1 means node v not visited; when visited parent[v] is set
    stack=new int[ ut->nnodes ];
    stackptr=-1;    // Empty stack
    restart(edge);     
}
    
// kliu need cleanup of allocated memory!
PaddedShortSubtreeDFSIterator::~PaddedShortSubtreeDFSIterator() {
  delete (parent);
  delete (stack);
}

bool PaddedShortSubtreeDFSIterator::at_end_subtree(){
    return stackptr==-1;    
}

int PaddedShortSubtreeDFSIterator::current(){
    if (stackptr==-1) {return -1;}
    return stack[stackptr];
}
    
void PaddedShortSubtreeDFSIterator::next(){
    if (stackptr==-1) {return;}
    
    // Look for the next node
    // Pop top
    int t=stack[stackptr]; stackptr--;
    // Push all adjacent nodes not visited
    UTNode* tn=ut->nodelist[t];
    for (int j=0;j<tn->nadj;j++) {
        int nj=tn->adj[j];
        if (parent[nj]>=0) {continue;}  // j visited
        stackptr++;           // Push j to top of stack
        stack[stackptr]=nj; 
        parent[nj]=t;          // Set parent of j
    }
}
    
void PaddedShortSubtreeDFSIterator::start_subtree(int subtreeroot){
    startnode=subtreeroot;
    // this is bizarre for startnode == subtreeroot
    // later on will try to look up branch length of subtreeroot to subtreeroot
    // and will fail
    parent[startnode]=startnode;   // visited
    stackptr=0;
    stack[stackptr]=startnode;     // Top of stack
}

void PaddedShortSubtreeDFSIterator::restart(const int* edge){
    int i;
    for (i=0;i<ut->nnodes;i++) {parent[i]=-1;} 
    parent[edge[0]]=1;     // Visited
    parent[edge[1]]=1;     // Visited
}    







/**************************
  Helper classes for PaddedSubtreeGraph
*/


PaddedSubtreeGraphFinder::PaddedSubtreeGraphFinder(const UnrootedTree* utin) {
    ut=utin;
}


Decomp** PaddedSubtreeGraphFinder::paddedSubTree(const int* edge, int p, bool pass_clusters) {
    //  Do DFS for each of the subtrees; compute the distance to the roots of the subtrees for each subtree
    //  Returns an array of size two
    //  First: clusters of padded short subtree
    //  Second: NULL if pass_clusters=false
    //          the clusters of each of the subtrees excluding those in the short subtree if pass_clusters=true
    
    Decomp** dcplist=new Decomp*[2];
    Decomp* dcp=new Decomp();
    Decomp* dcp2;
    if (pass_clusters) {
        dcp2=new Decomp();
    } else {
        dcp2=NULL;
    }
    dcplist[0]=dcp; dcplist[1]=dcp2;
    
    // kliu walk adjacency lists of two endpoints of edge edge
    // pull of roots of subtrees connected to those two endpoints
    // probably just four subtrees connected to these two endpoints
    //  Collect subtree root
    UTNode* n0, *n1;
    UTNode** nodelist=ut->nodelist;
    n0=nodelist[edge[0]];
    n1=nodelist[edge[1]];
    int* subtreerootlist=new int[n0->nadj + n1->nadj-2];
    int strj=0,i;
    for (i=0;i<n0->nadj;i++) {
        if (n0->adj[i]==edge[1]) {continue;}
        subtreerootlist[strj]=n0->adj[i]; strj++;
    }
    
    for (i=0;i<n1->nadj;i++) {
        if (n1->adj[i]==edge[0]) {continue;}
        subtreerootlist[strj]=n1->adj[i]; strj++;
        
    }

    // kliu testing - correct - finding the four subtrees correctly
    // omits endpoints of input edge in subtree location above
    //cout << "number of subtrees: " << strj << endl;
    
    // Do DFS for each subtree; compute the distances from the leaves to the subtree root
    PaddedShortSubtreeDFSIterator* di=new PaddedShortSubtreeDFSIterator(ut,edge);

    int nnodes=ut->nnodes;
    int* tmplist=new int[nnodes];                        // Store taxon nodes in subtree
    float* dist2str=new float[nnodes];                    // Store distances from each node in subtree to subtreeroot
    int clusize,sti;
    for (sti=0;sti<strj;sti++) {   // For each subtree
        for (i=0;i<nnodes;i++) {dist2str[i]=-1;}         // Initialize
        int subtreeroot=subtreerootlist[sti];
        di->start_subtree(subtreeroot);
        clusize=0;

        while(! di->at_end_subtree()) {
            int ci=di->current();    // Current node
            int pci=di->parent[ci];  // Current node's parent
            if (pci==subtreeroot) {  // Update dist2str
	      // kliu - this lookup seems to fail for each subtree - fortunately gets 0 in every case
	      // kliu - this happens because di->start_subtree(subtreeroot) call above
	      // sets the parent of subtreeroot to subtreeroot!!!
	      // then this edgelen call will fail
	      // don't do this for subtreeroot == ci
	      if (ci != subtreeroot) {
                dist2str[ci]=ut->edgelen(subtreeroot,ci);
		//		cout << "heya " << dist2str[ci] << endl;
	      }
	      else {
		dist2str[ci] = 0.0;
	      }
            }  
            else {
                dist2str[ci]=ut->edgelen(pci,ci) + dist2str[pci];
            }
            di->next();
            if (nodelist[ci]->nadj==1) {  // Taxon
                tmplist[clusize]=ci;
                clusize++;
            }    
        }

        // Compute p shortest distances
        set<float, less<float> > pdist;
        for (int i=0;i<clusize;i++) {
            if (dist2str[tmplist[i]]>-1) {
                float dd=dist2str[tmplist[i]];
                    pdist.insert(dd);
            }
        }        

       
        set<float, less<float> >::iterator sit=pdist.begin();
        int i=0;
        float f;   // p'th smallest distance from any taxon to subtree root
    
	// rank leaves by distance and select top p 
	// *that's* how the padding works
	// don't just select four closest leaves in short quartet around edge e
	// select pth closest leaves away from edge e
        while(sit!=pdist.end() && i<p) { 
            f=*sit; 
            i++; 
            sit++;
        }
         // count number of taxa shorter than threshold distance f
        int cnt=0;
        for (int i=0;i<clusize;i++) {
            if (dist2str[tmplist[i]]<=f) {
                cnt++;
            }
        }
       // Store the cluster below subtreeroot not in padded short sutbree
        int cnt2=0;    
        if (pass_clusters) {
	  // kliu cleaned up in delete of Decomp* dcp2 linked list of subproblems
            DecompSubProblem* dspclu=new DecompSubProblem(clusize-cnt);
                   
            for (i=0;i<clusize;i++) {
                if (dist2str[tmplist[i]]>f) {
                    dspclu->nodelist[cnt2]=tmplist[i];
                    cnt2++;
                }
            }
            dcp2->addSubproblem(dspclu);
        }
        
	// hmm - leaving this dynamic memory around until
	// later for cleanup can be messy

	// kliu - hold off on this for now
	// if the creation of the padded short subtree graph is indeed
	// what is causing the large memory usage
	// then need to check number of edges in padded short subtree graph
	// to verify
	//
	// kliu - this is where it's generating lots of memory usage
        // Create new subproblem to store the short subtree leaves
	// storage short subtree X(e) on this edge e is proportional to number of shortest quartet leaves
	// weird! varies between [1,12]??? due to padding!!!!
	//        cout << "cnt=" << cnt << endl;  
        cnt2=0;      
	// kliu - this memory gets cleaned up when Decomp* linked list of subproblems gets cleaned up
        DecompSubProblem* dsp=new DecompSubProblem(cnt);
        for (int i=0;i<clusize;i++) {
            if (dist2str[tmplist[i]]<=f) {
                dsp->nodelist[cnt2]=tmplist[i];
                cnt2++;
            }
        }    
        dcp->addSubproblem(dsp); 
    }    
    
    // kliu - possible some memory is being leaked above - 
    // every ~100 edges virt size grows by maybe 100 MB or so
    // no destructor for PaddedSubtreeDFSIterator object!!!

    delete di;
    delete tmplist;
    delete dist2str;
    delete subtreerootlist;
    
    // Test information
//    Decomp* dd=new Decomp(*dcp);
//    dd->translate(ut);
//    cout << "$"<< endl;
//    dd->dump(cout);
//    cout << "@"<< endl;
//    delete dd;
    
    return dcplist;
}


/*************************************************************************************
Padded Short Subtree Graph
*/


// kliu this constructor is taking a really long time and space on
// a ~200K taxon input tree
PaddedShortSubtreeGraph::PaddedShortSubtreeGraph(const UnrootedTree* ut, int p) : DCMGraph() {
    // Initialize
    int i;
    nnodes=ut->ntaxa;
    nodelist=new GNode*[nnodes];
    for (i=0;i<nnodes;i++) {
        nodelist[i]=new GNode();
        nodelist[i]->label=i;
        nodelist[i]->nadj=0;
    }
    
    // For each edge, compute the padded short subtree
    UTEuclideanTourIterator* uteti=new UTEuclideanTourIterator(ut);
    PaddedSubtreeGraphFinder* psgf=new PaddedSubtreeGraphFinder(ut);
    
    int* ssttaxalist=new int[nnodes];

    int numEdgesDone = 0;
    
    // kliu - I think this walks through all edges
    // uses order from "euclidean" tour - not really a tour
    // just some DFS order??
    // this is the optimal DCM3 decomposition that constructs short subtree graph on *all*
    // edges in input tree
    //
    // instead of fast suboptimal DCM3 decomposition that just uses short subtree around the centroid
    // edge
    // 
    // this loop itself is already linear work
    while(! uteti->at_end()) {
        int* edge=uteti->current();
        if (ut->nodelist[edge[0]]->nadj==1 || ut->nodelist[edge[1]]->nadj==1) {uteti->next(); continue;} // External edge    
        if (edge[0]>edge[1]) {uteti->next(); continue;}
//        cout << edge[0] << " " << edge[1] << endl;
	// *lots* and lots of memory allocation here
	// kliu - this is just finding short subtree around current edge "edge"
	// nodes of short subtree for a clique for this edge in short subtree graph
	// finding max clique in short subtree graph is equivalent to
	//   finding biggest set of these "leaves of short quartets around any edge e" that are 
	//   included in as many edges as possible (max clique in short subtree graph)
        Decomp** dcplist=psgf->paddedSubTree(uteti->current(),p,false);

        // Aggregate the taxa in dcplist[0]
        int i,cnt=0;
        
        DecompSubProblem* head=dcplist[0]->head;
        while(head!=NULL) {
            cnt=cnt+head->nnodes;
            head=head->next;
        }

        head=dcplist[0]->head;
        cnt=0;
        while(head!=NULL) {
            for (i=0;i<head->nnodes;i++) {
                ssttaxalist[i+cnt]=ut->nodelist[head->nodelist[i]]->label;
            }    
            cnt=cnt+head->nnodes;
            head=head->next;
        }
        
        // kliu - hmm... we keep adding more and more edges to the adjacency list structure
	// for this padded short subtree graph
	// as that keeps going, probably approaches quadratic!
	// keep track of size???
	// clique on all n taxa -> n (n-1) size
	//
	// kliu short subtree graph has unit edge weights 
        // Make the taxa into a clique in the graph
        make_clique(cnt,ssttaxalist,1.0);

        
//        cout << "Short subtree:" << endl;
//        dcplist[0]->translate(ut);
//        dcplist[0]->dump(cout);
        
        delete (dcplist[0]);
        delete (dcplist);
        uteti->next();

	//	cout << "Edge " << numEdgesDone << " done." << endl;
	numEdgesDone++;
    }
    
    // Clear memory
    delete uteti;
    delete psgf;
    delete ssttaxalist;
}

/*************************************************************************************
Adaptive Padded Short Subtree Graph
*/


AdaptivePaddedShortSubtreeGraph::AdaptivePaddedShortSubtreeGraph(const UnrootedTree* ut, int maxsubproblemsize) : DCMGraph() {
    // Initialize
    int i;
    nnodes=ut->ntaxa;
    nodelist=new GNode*[nnodes];
    for (i=0;i<nnodes;i++) {
        nodelist[i]=new GNode();
        nodelist[i]->label=i;
        nodelist[i]->nadj=0;
    }
    
    // For each edge, compute the largest padded short subtree
    UTEuclideanTourIterator* uteti=new UTEuclideanTourIterator(ut);
    PaddedSubtreeGraphFinder* psgf=new PaddedSubtreeGraphFinder(ut);
    
    int* ssttaxalist=new int[nnodes];
    
    while(! uteti->at_end()) {
        int* edge=uteti->current();
        if (ut->nodelist[edge[0]]->nadj==1 || ut->nodelist[edge[1]]->nadj==1) {uteti->next(); continue;} // External edge    
        if (edge[0]>edge[1]) {uteti->next(); continue;}
//        cout << edge[0] << " " << edge[1] << endl;

        Decomp** largest_subp=NULL;  // Largest subproblem smaller than maxsubproblemsize
        Decomp** dcplist;
        int i,cnt;
        
        for (int p=1;p<=nnodes;p++) {
            dcplist=psgf->paddedSubTree(uteti->current(),p,false);  // A list of single subproblem    

        // Find the number of taxa in subproblem        
            cnt=0;
            DecompSubProblem* head=dcplist[0]->head;
            while(head!=NULL) {
                cnt=cnt+head->nnodes;
                head=head->next;
            }
            
//            cout << "p=" << p << ", cnt=" << cnt << endl;
            
            if (p==1) {largest_subp=dcplist; continue;}   // Always p is at least 1
            
            if (cnt>maxsubproblemsize) {
                delete dcplist[0];  // Delete this subproblem
                delete dcplist;
                break;
            } else {
                delete largest_subp[0];  // Delete last subproblem
                delete largest_subp;
                largest_subp=dcplist;    // This is better
            }    
        }

        // Aggregate the taxa in dcplist[0]
        dcplist=largest_subp;
        DecompSubProblem* head=dcplist[0]->head;  // Find end of the list
        cnt=0;

        while(head!=NULL) {
            for (i=0;i<head->nnodes;i++) {
                ssttaxalist[i+cnt]=ut->nodelist[head->nodelist[i]]->label;
            }    
            cnt=cnt+head->nnodes;
            head=head->next;
        }

        // Make the taxa into a clique in the graph
        make_clique(cnt,ssttaxalist,1.0);
    
//        cout << "Short subtree:" << endl;
//        dcplist[0]->translate(ut);
//        dcplist[0]->dump(cout);
        
        delete dcplist[0];
        delete dcplist;
        
        
        uteti->next();
    }
    
    // Clear memory
    delete uteti;
    delete psgf;
    delete ssttaxalist;
}




/******************************************************
 DCM-1:
Input: Distance matrix, threshold
Algorithm: 
    Threshold graph
    greedy triangulation heuristic
    perfect elimination ordering
    enumeration of maximal cliques in a triangulated graph
*/

Decomp* DCM1_Factory::decompose(const DistMatrix& dm, float threshold){
    DCMGraph g;
    PEO* peo;
    g.asThresholdGraph(dm,threshold);
    peo=g.GreedyTriangulate();
    Decomp* dcp=g.EnumerateMaxCliques(peo);
    delete peo;
    return dcp;
}    

/******************************************************
 DCM-2:
Input: Distance matrix, threshold
Algorithm: 
    Threshold graph
    greedy triangulation heuristic
    perfect elimination ordering
    enumeration of maximal cliques in a triangulated graph
    minimal vertex separator
    decomposition with minimal vertex separator

*/

Decomp* DCM2_Factory::decompose(const DistMatrix& dm, float threshold){
    DCMGraph g;
    PEO* peo;
    g.asThresholdGraph(dm,threshold);
    peo=g.GreedyTriangulate();
    Decomp* dcp=g.EnumerateMaxCliques(peo);
    delete peo;
    DecompSubProblem* sep=g.MinVertexSeparator(*dcp);
    Decomp* dcp2=g.DecomposebyMinVertexSeparator(*sep);
   
//    delete sep;
//    delete dcp;
    return dcp2;
}


/******************************************************
DCM-3
Input: Guide tree, padding constant $p$
Algorithm: 
    padded short subtree graph, 
    perfect elimination ordering, 
    enumeration of maximal cliques in a triangulated graph, 
    minimal vertex separator, 
    decomposition with minimal vertex separator
*/

Decomp* DCM3_Factory::decompose(const UnrootedTree* ut, int p) {
  // in gdb, this graph object creation seems to be the current
  // stumbling block on input with 218K taxa
    PaddedShortSubtreeGraph* pssg=new PaddedShortSubtreeGraph(ut,p);

    // kliu
    //    cout << "hello world! padded short subtree graph ready." << endl;

    PEO* peo=pssg->PerfectEliminationOrdering();
    Decomp* dcp=pssg->EnumerateMaxCliques(peo);
    // no destructor or constructor!
    delete peo;
    DecompSubProblem* sep=pssg->MinVertexSeparator(*dcp);
    Decomp* dcp2=pssg->DecomposebyMinVertexSeparator(*sep);
    
    // Clear memory
    delete pssg;
    // kliu - why is this commented out?
    // these are probably supposed to be deleted elsewhere
    // dcp object deletion is causing problems - likely that linked list isn't set up right??
    delete dcp;
    // deleting above dcp object will also delete the object pointed to by this sep pointer
    /* kliu - don't do this for the above reason!!! delete sep; */
    
    return dcp2;
}    

/******************************************************
 Median edge decomposition:
Input: Guide tree
Algorithm: 
    median edge finding, 
    decomposition with minimal vertex separator
*/


Decomp* MEDecomp_Factory::decompose(const UnrootedTree* ut, int p) {
    int* me;
    int i,j;
    
    PaddedSubtreeGraphFinder psgf(ut);
    
    me=ut->findMedianEdge();   // Median edge
//    cout << "Median edge: " << me[0] << "," << me[1] << endl;
    Decomp** dcplist=psgf.paddedSubTree(me, p, true);  // Padded short subtree
    
    // Decomposition
    // Count the number of subproblems
    DecompSubProblem* head=dcplist[0]->head;
    DecompSubProblem* head2;
    int ndc=0;  // number of subproblems
    while(head!=NULL) {ndc++; head=head->next;}
    
    // Compute the union of short subtree taxa
    int nsst=0;
    head=dcplist[0]->head;
    while(head!=NULL) {nsst=nsst+head->nnodes; head=head->next;}
    
    int* ssttaxalist=new int[nsst];
    head=dcplist[0]->head;
    j=0;
    
    
    while(head!=NULL) {
        for (i=0;i<head->nnodes;i++) {
            ssttaxalist[j]=head->nodelist[i]; j++;
        }    
        head=head->next;
    }
    // For each cluster, put short subtree taxa into each of the decomposition
    
    DecompSubProblem* dspst=dcplist[1]->head;
    Decomp* me_dcp=new Decomp();
    
    int* i2label=new int[ut->nnodes];
    for (i=0;i<ut->nnodes;i++) {
        if (ut->nodelist[i]!=NULL) {
            i2label[i]=ut->nodelist[i]->label;
        }    
    }
    
    bool emptycomponent=false;   // Test if already one subtree in the decomposition is already covered entirely by the short subtree
    
    while(dspst!=NULL) {
        if (dspst->nnodes==0) {
            if (emptycomponent) {
                dspst=dspst->next;
                continue;
            } else {
                emptycomponent=true;
            }    
        }    
        DecompSubProblem* dspnew=new DecompSubProblem(nsst+dspst->nnodes);
        for (i=0;i<nsst;i++) {dspnew->nodelist[i]=ssttaxalist[i];}
        for (i=0;i<dspst->nnodes;i++) {dspnew->nodelist[i+nsst]=dspst->nodelist[i];}
        me_dcp->addSubproblem(dspnew);
        dspst=dspst->next;
    }

    me_dcp->translate(ut); // translate node indices to labels

    // Clear memory
    delete dcplist[0];
    delete dcplist[1];
    delete dcplist;
    delete ssttaxalist;
    delete i2label;
    
    return me_dcp;
}    





/******************************************************
 DCM-4:
Input: Guide tree
Algorithm: 
    padded short subtree graph
    perfect elimination ordering
    enumeration of maximal cliques in a triangulated graph
*/

Decomp* DCM4_Factory::decompose(const UnrootedTree* ut, int p) {
    PaddedShortSubtreeGraph* pssg=new PaddedShortSubtreeGraph(ut,p);
    PEO* peo=pssg->PerfectEliminationOrdering();
    Decomp* dcp=pssg->EnumerateMaxCliques(peo);
    
    // Clear memory
    delete pssg;
    delete peo;
    return dcp;
}




/*************************************************************************************
Adaptive DCM-4:
Input: Guide tree
Algorithm: 
    padded short subtree graph
    perfect elimination ordering
    enumeration of maximal cliques in a triangulated graph    
*/


Decomp* AdaptiveDCM4_Factory::decompose(const UnrootedTree* ut, int maxprobsize) {
    AdaptivePaddedShortSubtreeGraph* pssg=new AdaptivePaddedShortSubtreeGraph(ut,maxprobsize);
    PEO* peo=pssg->PerfectEliminationOrdering();
    Decomp* dcp=pssg->EnumerateMaxCliques(peo);
    
    // Clear memory
    delete pssg;
    delete peo;
    return dcp;
}


