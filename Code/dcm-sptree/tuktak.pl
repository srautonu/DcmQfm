
#$src_directory = $ARGV[0]; # directory path of the percentage directory (e.g., locus2)


sub badInput {
  my $message = "Usage: perl $0
	this file needs some hard_coded stuffs!, you need to mention $loci, $percent etc.\n
	give the directory path of the 'sim.percent' dir.\n
	example perl simulation_17taxa /u/bayzid/Research/simulation_study/tools/exes/inputs/17taxa_simulation/sim20percent/locus2\n ";
  print STDERR $message;
  die "\n";
}
#badInput() if not defined $src_directory;

my $perl_scripts = "/v/filer4b/v20q001/bayzid/Research/simulation_study/tools/run_scripts";

#$file = "/projects/sate9/bayzid/dcm-sptree/mammals/adaptive-dcm/scale5d.200g.500b/mpest/R1/itr6/mpest/test.mpest.score";



#`grep -e 'mpest' Best.1.tre| sed -e "s/ .*\[/ /g" -e "s/\].*//g" >> justtest`;

#`grep -e 'mpest' Best.1.tre| sed -e "s/ .*\\[/ /g" -e "s/\\].*//g"|tail -n1|sed 's/ //g' >> justtest`;

=st
open(INFO, $file);		# Open the file
@lines = <INFO>;		# Read it into an array
close(INFO);

print @lines;




	$max_index = 0;
	$i = 1;
	$max = $lines[0];
	foreach $line(@lines)
	{
		if ($line >= $max)  # ekhane > or ge die fist max or last max control kora jai. last max (ge) newatai hoito bhalo hobe
		{
			$max = $line;
			$max_index = $i;
		}
	$i++;
	}

print "\n max: $max and $max_index"
=cut

$dir = "/scratch/cluster/bayzid/new-stat-binning/avian/noscale.200g.500b.50";
$rf_dir = "$dir/rf_scores";
`mkdir $rf_dir` if not -e $rf_dir;

for ($r=1; $r <=20;$r++)
{
	`python $perl_scripts/getFpFn.py -t /projects/sate/smirarab/avianjarvis/sim/st.avian/true.tre -e $dir/R$r/mpest/mpest.all_greedy.newick.with.support >> $dir/rf_scores/rf_mpest_wbin`;
	`python $perl_scripts/getFpFn.py -t /projects/sate/smirarab/avianjarvis/sim/st.avian/true.tre -e $dir/R$r/mrp/mrp.all_greedy.newick.with.support >> $dir/rf_scores/rf_mrp_wbin`;
	`python $perl_scripts/getFpFn.py -t /projects/sate/smirarab/avianjarvis/sim/st.avian/true.tre -e $dir/R$r/greedy/greedy.all_greedy.newick.with.support >> $dir/rf_scores/rf_greedy_wbin`;
}
`perl $perl_scripts/calculate_missingbranchrate_python.pl $dir/rf_scores/rf_mpest_wbin`;
`perl $perl_scripts/calculate_missingbranchrate_python.pl $dir/rf_scores/rf_mrp_wbin`;
`perl $perl_scripts/calculate_missingbranchrate_python.pl $dir/rf_scores/rf_greedy_wbin`;
