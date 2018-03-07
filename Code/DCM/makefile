CC = g++ 
OUTNAME = dcm
LIBFLAG = 
#DEBUG   = -g -DDEBUG
DEBUG	= -O2


all:   dist.o graph.o dcm.o tree.o main.o
	$(CC) $(DEBUG) dcm.o dist.o graph.o tree.o main.o \
		-o $(OUTNAME) $(LIBFLAG)

dcm.o: dcm.cpp dcm.h dist.h graph.h tree.h
	$(CC) $(DEBUG) -c dcm.cpp -o dcm.o	

dist.o: dist.cpp dcm.h dist.h graph.h tree.h
	$(CC) $(DEBUG) -c dist.cpp -o dist.o	

graph.o: graph.cpp dcm.h dist.h graph.h tree.h
	$(CC) $(DEBUG) -c graph.cpp -o graph.o	

tree.o: tree.cpp dcm.h dist.h graph.h tree.h
	$(CC) $(DEBUG) -c tree.cpp -o tree.o	

main.o: main.cpp dcm.h dist.h graph.h tree.h
	$(CC) $(DEBUG) -c main.cpp -o main.o	
clean:
	-rm -f *.o $(OUTNAME)

