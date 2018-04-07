#!/lusr/bin/perl -w

#Author: Md. Shamsuzzoha Bayzid
#September 05, 2014

#use strict;
use warnings;
use Getopt::Long;

#output
sub badInput {
  my $message = "Usage: perl $0 score a species tree with respect to a set of gene trees based on quartet support. It calculates the total number of quartets in the gene trees that are satisfied by the species tree.
	-g=<gene_trees_file>
	-s=<species_tree_file>
	-o=<output_file>
";
  print STDERR $message;
  die "\n";
}

GetOptions(
	"g=s"=>\my $gtFile,
	"s=s"=>\my $spFile,
	"o=s"=>\my $output,
);

badInput() if not defined $gtFile;
badInput() if not defined $spFile;


# generating the weighted quartets from the input gene trees.

my $weighted_quartets = "wquart.tmp";
`./quartet-controller.sh $gtFile $weighted_quartets`;

# finding the score of the species tree

`perl score_wcomp.pl -sp $spFile -qt $weighted_quartets -o $output`;
# removing the temporary weighted quartet files

`rm $weighted_quartets`;

