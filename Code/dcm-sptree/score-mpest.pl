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
	-infile=<input gene trees. give full path.>
	-splist=<spcies-list file>
	-sptree=<species tree to be scored. give full path. control file and score file will be created here>
	-output=<outputFIle. it is not mandatory. if not defined the score will be printed in standard output>";
  print STDERR $message;
  die "\n";
}

GetOptions(
	"infile=s"=>\my $inFile,
	"splist=s"=>\my $spList,
	"sptree=s"=>\my $spFile,
	"output=s"=>\my $outFile,
);

# make sure you are using 64 bit machine

#########################################################################
badInput() if not defined $inFile;
badInput() if not defined $spList;
badInput() if not defined $spFile;
#badInput() if not defined $outFile;

#  /projects/sate7/tools/bin/mpest.1.4.64bit control-Best.1.size-15.relaxed.subsets.1.itr1-1-EWCI4|sed -n '15p'

# first find the directory where the spFile is located.

my $indir;
my $inFileName;
if ($inFile =~ /(.*)(\/)(.*)/){
	$indir = $1;
        $inFileName = $3;
}

# same for spFile
my $spdir;
my $spFileName;
if ($spFile =~ /(.*)(\/)(.*)/){
	$spdir = $1;
        $spFileName = $3;
}


# now creating the symbolic link of the input gene file at spdir

`ln -s $inFile $spdir/$inFileName`;

# now creating the control file

my $controlFile = "$spdir/control-score_$spFileName";
open(OUT, ">", $controlFile) or die "can't open $controlFile: $!";

# finding the number of genes and number of taxa

$ngene = `grep -c ".*" $inFile`;
$ntaxa = `grep -c ".*" $spList`;

chomp($ntaxa);
chomp($ngene);
#print "\n this is $ngene";
print OUT "$inFileName";
print OUT "\n0\n1234\n$ngene $ntaxa";

my $splist_contents = `cat $spList`;
print OUT "\n$splist_contents";

my $sptree_contents = `cat $spFile`;
print OUT"\n2"; # option 2 is for scoring a tree
print OUT "\n$sptree_contents";

close(OUT);
# now scoring the tree

# grep -e 'mpest' Best.1.tre | sed -e "s/ .*\[/ /g" -e "s/\].*//g"|tail -n1|sed 's/ //g'   # to get the likelihood value
#$initial_dir = "/u/bayzid/Research/simulation_study/tools/run_scripts/dcm-sptree"; # we have to here
chdir $spdir;

`/projects/sate7/tools/bin/mpest.1.4.64bit $controlFile`;
#`/projects/sate7/tools/bin/mpest.1.4.64bit $controlFile >> $tFile`;




=st
if (defined $outFile)
{ 
print OUTt "\n I am inside the mpest run";
`/projects/sate7/tools/bin/mpest.1.4.64bit $controlFile|sed -n '15p' >> $outFile`;}
else 
{
	print OUTt "\n I am inside the mpest run";
 print `/projects/sate7/tools/bin/mpest.1.4.64bit $controlFile|sed -n '15p'`;}
#print "done.\n";
=cut
