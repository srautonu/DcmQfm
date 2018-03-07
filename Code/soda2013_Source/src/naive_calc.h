#ifndef NAIVE_CALC_H
	#define NAIVE_CALC_H

	#include <vector>
	#include <string>
	#include "int_stuff.h"
	#include "triplet_calc.h"
	#include "quartet_calc.h"
	#include "output_handler.h"

	using namespace std;

	class NaiveCalc : public TripletCalc, public QuartetCalc
	{
		public:
			INTTYPE_REST calculateTripletDistance(RootedTree *t1, RootedTree *t2);
			INTTYPE_N4 calculateQuartetDistance(UnrootedTree *t1, UnrootedTree *t2);
			void printTriplets(RootedTree *t);
			void printQuartets(UnrootedTree *t);

		private:
			INTTYPE_N4 compareVectors(vector<string> *resOne, vector<string> *resTwo);
			void calcTriplets(RootedTree *t);
			void calcQuartets(UnrootedTree *ut, bool printAnchor = false);
			bool isAlpha(RootedTree *p1, RootedTree *p2, RootedTree *p3, RootedTree *p4);
			OutputHandler *oh;
	};
#endif