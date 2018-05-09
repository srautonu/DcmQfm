#!/lusr/bin/perl -w

#use lib "/projects/sate3/tools/bin/bioPerl-1.5.2/lib/perl5";
#use lib "/u/bayzid/Research/simulation_study/tools/bioPerl-1.5.2/lib/perl5";

#use lib "/projects/sate3/tools/bin/bioPerl-1.5.1-rc3";
#use lib "/u/bayzid/Research/simulation_study/tools/bioPerl-1.5.1-rc3/";  # eta korte hobe export PERL5LIB=/u/bayzid/Research/simulation_study/tools/bioperl-1.5.1-rc3/

#use lib "/u/bayzid/Research/simulation_study/tools/BioPerl-1.5.9._2/";

use lib "/u/bayzid/Research/simulation_study/tools/BioPerl-1.6.901/"; #BioPerl-1.6.901

use Bio::TreeIO;
use Bio::Tree::TreeFunctionsI;
use strict;
#use Bio::AlignIO;
use warnings;
use Getopt::Long;

sub badInput {
  my $message = "Usage: perl $0 this takes a set of trees and output only the binary ones among the inputs
	-i=<tree>  #input trees
	-o=<output tree>"; # binary trees
  print STDERR $message;
  die "\n";
}

GetOptions(
	"i=s"=>\my $tree,
	"o=s"=>\my $outtree,
);

badInput() if not defined $tree;



open(INFO, $tree);		# Open the file
my @lines = <INFO>;		# Read it into an array
close(INFO);	


my $in = Bio::TreeIO->new(-file => "$tree",
			   -format => 'newick');

my $out = Bio::TreeIO->new(-file => ">$outtree",
			    -format => 'newick');

while( my $gt = $in->next_tree ) 
	{

		my $root = $gt->get_root_node;
		if ($gt->is_binary($root)) 
			{
				$out->write_tree($gt);
			}

		
		}


####################
print "\ndone.\n";
