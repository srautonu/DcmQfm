#!/lusr/bin/perl -w

#use strict;
#use warnings;
#no warnings 'uninitialized';
use Getopt::Long;

#input: tree with both branch lengths and support values
#)sv:br

#output: see below


##########     EXAMPLE CALL ################


#perl ~/Research/simulation_study/tools/run_scripts/dcm-sptree/score-quartet-dcm.pl -indir /projects/sate9/bayzid/dcm-sptree/mammals/adaptive-dcm/scale5d.200g.500b/mpest -gtfile Best.1 -spfile size-20.superfine-mrl -truet /projects/sate/smirarab/avianjarvis/sim/st.mam/true.tre -rep 2

#perl ~/Research/simulation_study/tools/run_scripts/dcm-sptree/score-quartet-dcm.pl -indir /projects/sate9/bayzid/dcm-sptree/mammals/adaptive-dcm/scale5d.200g.500b/mpest -gtfile Best.1 -spfile size-20.superfine-mrl -truet /projects/sate/smirarab/avianjarvis/sim/st.mam/true.tre -rep 3

sub badInput {
  my $message = "Usage: perl $0 finds the quartet scores of the species trees estimated in different iterations. it will create a file containing the score insied each replicate. also it finds the rf_score for the best tree (rf_bestq).
	-indir=<input directory. example: /projects/sate9/bayzid/dcm-sptree/mammals/adaptive-dcm/scale5d.200g.500b/mpest/>
	-gtfile=<just the name of the gene tree file. example: Best.1>
	-spfile=<just the name of the species tree file. example: size-20.superfine-mrl>
	-truet=<true species tree. this will be used to find the rf score>	
	-rep=<number of replicates.>";
  print STDERR $message;
  die "\n";
}

GetOptions(
	"indir=s"=>\my $inDir,
	"truet=s"=>\my $model,
	"gtfile=s"=>\my $gtFile,
	"spfile=s"=>\my $spFile,
	"rep=s"=>\my $rep,
);

# make sure you are using 64 bit machine

#########################################################################
badInput() if not defined $inDir;
badInput() if not defined $gtFile;
#badInput() if not defined $model;
badInput() if not defined $spFile;
badInput() if not defined $rep;


$perl_scripts = "/v/filer4b/v20q001/bayzid/Research/simulation_study/tools/run_scripts";
$initial_dir = "/projects/sate7/rimpi/quartet_summary_wrapper"; # we have to be here
chdir $initial_dir;

## !!!!!!!!!!!!!!!!!! $method hard coded ...ekhane mpest method dewa hoise !!!!!!!!!!!!!!!!!!!!!!!





#badInput() if not defined $outFile;

#  /projects/sate7/tools/bin/mpest.1.4.64bit control-Best.1.size-15.relaxed.subsets.1.itr1-1-EWCI4|sed -n '15p'

# first find the directory where the spFile is located.

=st
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

=cut
# first create the weighted quartet file
#=st
=st
for ($r = 0; $r <= $rep; $r++){

	`quartet-controller.sh $inDir/R$r/Reps/$gtFile $inDir/R$r/Reps/$gtFile.wquart`;
}
=cut
# next score the species tree for all the species trees across the five iterations.
$method = "mpest"; # mpest or astral-exact, -heu

for ($r = 0; $r <= $rep; $r++){

	$score_dir = "$inDir/R$r/scores";
	`mkdir $score_dir` if not -e $score_dir;
	`rm $score_dir/quartet-scores_$spFile` if -e "$score_dir/quartet-scores_$spFile";	
	
	for ($i = 1; $i <= 5; $i++){ # 5 iterations hard coded
		
		`perl score_wcomp.pl -sp $inDir/R$r/itr$i/$method/$spFile -qt $inDir/R$r/Reps/$gtFile.wquart >> $score_dir/quartet-scores_$spFile`;
	}

}

#=cut
# now reading the quartet-score file to find the max number.
$method = "mpest";
$itr = 5;
$all_score_dir = "$inDir/all_scores";
`mkdir $all_score_dir` if not -e $all_score_dir;

$all_score = "$inDir/all_scores/all_quart_scores_$spFile-iter$itr";
#`rm $all_score` if -e $all_score;
open(OUT, ">", $all_score) or die "can't open $all_score: $!";

$rf_file_best = "$inDir/rf_scores/rf_bestq_$spFile-iter$itr";
`rm $rf_file_best` if -e $rf_file_best;

# this will be needed for the biological datasets to draw branch support

#$all_best_trees = "$inDir/all_scores/all_best_quart_trees";


for ($r = 0; $r <= $rep; $r++){
	
	$score_file = "$inDir/R$r/scores/quartet-scores_$spFile";
	open(INFO, $score_file);		# Open the file
	@lines = <INFO>;		# Read it into an array
	close(INFO);	

	$max_index = 0;
	$i = 1;
	$max = 0;

	foreach $line(@lines)
	{
		if ($i <=$itr){ # this is for limiting the iteration number
		#chomp($line);
		print "\n R$r	$line $max";
		if ($line >= $max)  # ekhane > or ge die first max or last max control kora jai. last max (ge) newatai hoito bhalo hobe
		{
			
			$max = $line;
			$max_index = $i;
		}
		} #endif
		else {last;}
	$i++;
	}
	
	print "\n\n max is $max\n";
	print OUT "$max";  # printing the quartet scores to a file
	

	# now finding the rf_rate of the best tree
	$tree_best = "$inDir/R$r/itr$max_index/$method/$spFile";
	#`cat $tree_best >> $all_best_trees`;

	print "\n tree best $tree_best";
	 #`python $perl_scripts/getFpFn.py -t $model -e $tree_best >> $rf_file_best`;  # this is commented out for the biological trees
	
}
close(OUT);

# now find the average

#`perl $perl_scripts/calculate_missingbranchrate_python.pl $rf_file_best`;

`perl $perl_scripts/calculate_average.pl $all_score`;

#print "done.\n";
