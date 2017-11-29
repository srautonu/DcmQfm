There are two steps:

1) create a file containing the induced quartets from the gene tree file
2) run Rezwana's script on the quartet file to estimate a species tree.

For (1), download quartet_count.sh, quartet-controller.sh and triplets.soda2013

You need to modify one line in "quartet_count.sh" file -- "/projects/sate7/tools/bin/triplets.soda2103". Please replace the path "/projects/sate7/tools/bin" by indicating your local directory where you saved "triplets.soda2013".

Then run the following command:

quartet-controller.sh <inputFile> <outputFile>

<inputFile>: a file containing the gene trees in newick format.
<outputFIle>: it will contain all the induced quartets and their frequency.

Step (2):  The executable for Rezwana's method is bestQuartet (with the option for "frequency of quartets" added). I will get the source code from Rezwana and send you asap inshAllah. bestQuartet takes two arguments: <inputFile> <outputTree>

inputFile contains a set of quartets with frequencies and outputTree is the name of the output file.

======
summarize_quartets_stdin.pl: Used to find the induced set of quartets.