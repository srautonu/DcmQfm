#!/lusr/bin/perl -w

#use strict;
#use warnings;
#no warnings 'uninitialized';
use Getopt::Long;

#input: tree with both branch lengths and support values
#)sv:br

#output: see below

sub badInput {
  my $message = "Usage: perl $0
	-indir=<full directory path. for example: /projects/sate9/bayzid/dcm-sptree/mammals/dactal/noscale.50g.500b/mpest>
	-rep=<number of replicates>
	-sItr=<starting iteration>
	-eItr=<ending iteration; if sItr =2 and eItr = 5, then it will skip itr 1 tree from computing greedy consensus>
        -fileName=<fileName of the species tree that are to be considered for GC. example: size-15.superfine-mrl>
	-method=<method; example: mpest. it will be used to match the directory path>
	";
  print STDERR $message;
  die "\n";
}

GetOptions(
	"indir=s"=>\my $inDir,
	"rep=s"=>\my $rep,
	"sItr=s"=>\my $sItr,
	"eItr=s"=>\my $eItr,
	"fileName=s"=>\my $fileName,
	"method=s"=>\my $method,
);

# make sure you are using 64 bit machine

#########################################################################
badInput() if not defined $inDir;
badInput() if not defined $rep;
badInput() if not defined $sItr;
badInput() if not defined $eItr;
badInput() if not defined $fileName;
badInput() if not defined $method;

# create a directory for greedy consensus.

for ($r = 1 ;$r <=$rep;$r++)
{
	my $greedy_dir = "$inDir/R$r/greedy";
	`mkdir $greedy_dir` if not -e $greedy_dir;
	
	#merging trees
	my $all_tree = "$greedy_dir/$fileName-itr_$sItr-$eItr";
	`cat /dev/null > $all_tree`; # removing the contents if any
	for ($i = $sItr; $i <= $eItr; $i++)
	{
		`cat $inDir/R$r/itr$i/$method/$fileName >> $all_tree`;
	}

	# now running greedy consensus
        my $output = "$greedy_dir/$fileName-itr_$sItr-$eItr.greedy";
        `/projects/sate7/smirarab/workspace/global/src/shell/greedy $all_tree 0 $output`;
}

# first find the directory where the spFile is located.
#my $controlFile = "$spdir/control-score_$spFileName";
#open(OUT, ">", $controlFile) or die "can't open $controlFile: $!";

print "done.\n";
