#!/lusr/bin/perl -w

#use strict;
use warnings;
#no warnings 'uninitialized';
use Getopt::Long;





my $condor_string = "+Group = \"GRAD\"
+Project = \"COMPUTATIONAL_BIOLOGY\"
+ProjectDescription = \"dcm-sptree\"

Universe = vanilla";

##########################################  hard code  ######################################3
$rep = 20;
my @model;
push(@model,"noscale.100g.500b");
push(@model,"noscale.200g.500b");
push(@model,"noscale.400g.500b");
push(@model,"noscale.800g.500b");
push(@model,"noscale.50g.500b");

push(@model,"noscale.200g.250b");
push(@model,"noscale.200g.1000b");
push(@model,"noscale.200g.1500b");
#push(@model,"noscale.200g.true");


push(@model,"scale2d.200g.500b");
push(@model,"scale2u.200g.500b");
push(@model,"scale5d.200g.500b");

my @spfile;
#push(@spfile,"size-20.superfine-mrl");
push(@spfile,"size-15.superfine-mrl");

$initial_dir = "/projects/sate7/rimpi/quartet_summary_wrapper";

$criteria = "quartet"; # likelihood or quartet
$decomp = "dactal"; # adaptive-dcm or dactal.
$condor_dir = "/projects/sate9/bayzid/dcm-sptree/mammals/$decomp/score-condor";
`mkdir $condor_dir` if not -e $condor_dir;

$method = "mpest"; # astral...astral er time e heu and exact change korte hobe score-quart-dcm and score-likelihood-dcm.pl file e
############################################################################################333
my $condor_score = "$condor_dir/condor_mpest_$criteria-score-iteration3";
open(OUT, ">", $condor_score) or die "can't open $condor_score: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/perl\n\n";

print OUT "Log = $condor_dir/logs/condor_$criteria-score.log
getEnv=True
initialdir = $initial_dir\n\n";

for $model(@model)
{
	for $spfile(@spfile)
		{	

		if($criteria eq "quartet"){
			print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/dcm-sptree/score-quartet-dcm.pl -indir /projects/sate9/bayzid/dcm-sptree/mammals/$decomp/$model/$method -gtfile Best.1 -spfile $spfile -truet /projects/sate/smirarab/avianjarvis/sim/st.mam/true.tre -rep $rep

Error=$condor_dir/logs/condor_quartet.$model.$spfile.err
Output=$condor_dir/logs/condor_quartet.$model.$spfile.out
Queue\n\n";}


		if($criteria eq "likelihood"){
		print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/dcm-sptree/score-likelihood-dcm.pl -indir /projects/sate9/bayzid/dcm-sptree/mammals/$decomp/$model/$method -gtfile Best.1 -spfile $spfile.resolved -truet /projects/sate/smirarab/avianjarvis/sim/st.mam/true.tre -splist /projects/sate9/bayzid/dcm-sptree/mammals/species.list -rep $rep

Error=$condor_dir/logs/condor_likelihood.$model.$spfile.err
Output=$condor_dir/logs/condor_likelihood.$model.$spfile.out
Queue\n\n";}
		}
}
