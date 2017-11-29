#!/lusr/bin/perl -w

#use strict;
use warnings;
#no warnings 'uninitialized';
use Getopt::Long;

#input: tree with both branch lengths and support values
#)sv:br

#output: see below

sub badInput {
  my $message = "Usage: perl $0
	-gdt=<guide tree>
	-ms=<maximum subset size>
	-dcm=<type of decomposition: dactal or adaptive -- dactal means decomposition will be dactal based. Adaptive is my adaptive dcm3 decomposition>
	-ps=<padding size: this is required for dactal based decomposition>
	-od=<output dir. the subsets will be created in this directory>
	-outgrp=<outgroups>
	-infile=<input gene trees. give full path. pruned gene trees will be created in this directory>
	-method=<set of methods you like to run. Example: -method \"phylonet-exact mpest\". IF YOUR METHOD CONTAINS PHYLONET-EXACT, YOU MUST HAVE TO DEFINE THE -strict option>
	-strict=<keeps the subsetsize strictly below (or equal) the maximum subsetsize. otherwise it can be little bit higher for some subsets. if you will run Phylonet-exact, you must have to use strict. Actually, this option will create two sets of subsets. One set is strict and another one is relaxed (for the methods that do not have the restriction as Phylo-exact). MP-EST will be using the relaxed set of subsets. if this option is not defined, only the relaxed set of subsets will be created>
	-padding=<if defined, it will add the outgroup to each subsets. otherwise it will not force the outgroup to be present in each subsets>";
  print STDERR $message;
  die "\n";
}

GetOptions(
	"gdt=s"=>\my $gdtree,
	"ms=s"=>\my $max_subset_size,
	"dcm=s"=>\my $decomp_type,
	"ps=s"=>\my $padding_size,
	"od=s"=>\my $outdir,
	"outgrp=s"=>\my $outgrp,
	"method=s"=>\my $methods,
	"infile=s"=>\my $inFile,
	"strict"=>\my $strict,
	"padding"=>\my $padding,
);

# WHAT YOU NEED TO INSTALL BEFORE RUNNING THIS SCRIPT.....


########## MAKE SURE YOU HAVE DENDROPY-3.8.1, REUP-1.1, SPRUCE-1.0, NEWICK-MODIFIED-1.3.1 INSTALLED AT --HOME=/U/BAYZID/ AND THE PYTHONPATH TO BE SET AS /U/BAYZID/LIB/PYTHON.

## ALSO, YOU NEED TO ADD IMPORT COPY TO /u/bayzid/lib/python/DendroPy-3.8.1-py2.7.egg/dendropy/scm.py ..I AM NOT 100% SURE IF THIS IS THE FILE WHERE I ADDED THE LINE "IMPORT COPY". BUT I HAD TO DO THAT IN ONE OF THE FILE. OTHERWISE I GOT THE FOLLOWING ERROR
##   tree_list = [copy.copy(i) for i in tree_list]
# NameError: global name 'copy' is not defined


# I changed the /u/bayzid/lib/python/reup/adapters.py -- in line 72 and 82. Previously it gave error if the overlap size is <=3. I changed it to 2. 

# once you created the condor files, you need to have export PATH=$PATH:/projects/sate7/tools/bin and export PATH=$PATH:/projects/sate3/tools/bin in the machine where you are submitting the condor files. Also you need to export FASTMRP

#########################################################################
badInput() if not defined $gdtree;
badInput() if not defined $max_subset_size;
badInput() if not defined $decomp_type;
badInput() if not defined $outdir;
badInput() if not defined $outgrp;
badInput() if not defined $inFile;
badInput() if not defined $methods;

badInput() if (($decomp_type eq "dactal") &&  (not defined $padding_size));  # padding size must be defined for dactal based decomposition

my $dcm = "/projects/sate7/tools/dactal-ship.v1/lisan_dcm/src";   # this is for adaptive dcm3 decomposition
my $dactal = "/projects/sate7/tools/Decomposition"; # this is for dacatal like decomposition
my $perl_scripts = "/v/filer4b/v20q001/bayzid/Research/simulation_study/tools/run_scripts";
my $phylonet = "/v/filer4b/v20q001/bayzid/Research/simulation_study/tools/exes"; 

#print "\n here is the outgroup $outgrp\n";
my @outgroups = split(/ /, $outgrp); # set of outgroups
my @methods = split(/ /, $methods); # set of outgroups

#badInput() if (($find = is_present(\@methods, "phylonet-exact")) && not defined $strict);
badInput() if ((is_present(\@methods, "phylonet-exact") == 1) && (not defined $strict));  # phylonet-exact but no -strict option is not acceptable
#{
#print "\n\n phylonet is found \n\n";
#}

# applying the dcm decomposition on the guide tree

if ($decomp_type eq "adaptive") 
{
	my $s = $max_subset_size - 2;  # it ensures the subsetsize. you can substract 2,3,4 etc depending on your datasets. THIS IS ONLY FOR ADAPTIVE. FOR DACTAL LIKE, WE DO NOT DO THAT
	`$dcm/dcm p $gdtree $s > $outdir/subsets`;

	`tail -n +2 $outdir/subsets > $outdir/size-$max_subset_size.subsets.v1`;  # remove the first line
	`rm $outdir/subsets`;  # remove this file


	# now removing the stars from beginning of each line
	my $subset_file = "$outdir/size-$max_subset_size.subsets.v1";
	my $subset_file_out = "$outdir/size-$max_subset_size.subsets.v2";
	open(INFO, $subset_file);		# Open the file
	my @lines = <INFO>;		# Read it into an array
	close(INFO);

	open(OUT, ">", $subset_file_out) or die "can't open $subset_file_out: $!";

	#my $start = 1;  # flag for first line
	foreach my $line (@lines){
	$line =~ s/\*//g; # 
	$line =~ s/^\s+//;
	$line =~ s/\s+$//; # to remove the trailing white spaces
	my $test = $line;   
	#$test =~ s/[^$FILTER]//go;

		if($test){
		print OUT "$line\n";
		}
      }
close(OUT);

}

if ($decomp_type eq "dactal") 
{
	#my $s = $max_subset_size - 2;  # 
	`python $dactal/prd_decomp.py $gdtree $max_subset_size $padding_size > $outdir/size-$max_subset_size.subsets.v1`;

	#`tail -n +2 $outdir/subsets > $outdir/size-$max_subset_size.subsets.v1`;  # remove the first line
	#`rm $outdir/subsets`;  # remove this file


	# now removing the stars from beginning of each line
	my $subset_file = "$outdir/size-$max_subset_size.subsets.v1";
	my $subset_file_out = "$outdir/size-$max_subset_size.subsets.v2";
	open(INFO, $subset_file);		# Open the file
	my @lines = <INFO>;		# Read it into an array
	close(INFO);

	open(OUT, ">", $subset_file_out) or die "can't open $subset_file_out: $!";

	#my $start = 1;  # flag for first line
	foreach my $line (@lines){
	$line =~ s/([^\[]*)//; # removing everything before the first [
	$line =~ s/[',\[\]]//g; # removing ' , [ and ]
	my $test = $line;   

		if($test){
		print OUT "$line";
		}
      }
close(OUT);

}





# process the subsets. remove the first line. then make individual files containing no more than $max_subset_size




#=st
# now creating one file for each line of the subsets.v2 file. Also check if all the outgroups are present in the file. if not add those.
my $subset_file = "$outdir/size-$max_subset_size.subsets.v2";
open(INFO, $subset_file);		# Open the file
my @lines = <INFO>;		# Read it into an array
close(INFO);

my $n_subsets = scalar(@lines);
print "\n number of subsets: $n_subsets";

my $i = 1;  # counter for subsets. it will be using for indexing the subset files
foreach $line (@lines)
	{
		chomp($line); # to remove trailing new lines from the $line
		my @taxa = split(/ /, $line);   # trailing space thakle sheta k ekta taxa dhore nibe. so make sure there is no space after the last taxa name
		my $n_taxa = scalar (@taxa);
	print "\n no of taxa before padding: $n_taxa";
		if (defined ($padding))  # add the outgroup to each subsets if user has defined padding
		{
			foreach $root (@outgroups)
			{
				$find = is_present(\@taxa, $root);
				if (!$find) {splice @taxa, 0, 0, $root;}  # it this root is not present then add it to the begining of the array.
			#last;	
			}
		}

	$n_taxa = scalar (@taxa);  # size of the @taxa
	print "\n no of taxa after padding: $n_taxa";
		
	my $subset_s = "$outdir/size-$max_subset_size.strict.subsets.$i"; # for phylonet
	open(OUT, ">", $subset_s) or die "can't open $subset_s: $!";
	
	if ((is_present(\@methods, "mpest") == 1)||(is_present(\@methods, "phylonet-heu") == 1)){
	my $subset_r = "$outdir/size-$max_subset_size.relaxed.subsets.$i";  # for mpest.
	open(OUT1, ">", $subset_r) or die "can't open $subset_r: $!";}

	if (is_present(\@methods, "mpest") == 1){
	my $specieslist = "$outdir/../size-$max_subset_size.specieslist.$i";
	open(OUT2, ">", $specieslist) or die "can't open $specieslist: $!";}
	# writing only the $max_subset_size elements of the array. so the last elements beyond this range will be discarded
	
	if (defined ($strict)){
	
		for ($j = 0; $j< $max_subset_size; $j++)
		{
			if ($j eq $n_taxa)
				{
					#print "\n inside the last";
					last;
				}  # do not exceed the size of the taxa array
			
			print OUT "$taxa[$j]\n";	# writing to strict file
			#print OUT1 "$taxa[$j]\n";	# writing to relaxed file 
			#print OUT2 "$taxa[$j] 1 $taxa[$j]\n";	
		}

		
		#$i++; # counter for subsets
		#last;
	 }  #end if
	#else {  
		#print "\n\n I am inside the else block\n\n";
	#relaxed file will be created whether or not strict option is defined.
	if (is_present(\@methods, "mpest") == 1){
		foreach $taxa (@taxa)
		{
		print OUT1 "$taxa\n";
		print OUT2 "$taxa 1 $taxa\n";	# species list is only for relaxed subsets. since we run mpest on relaxed subsets.
		}
	}

	if (is_present(\@methods, "phylonet-heu") == 1){
		foreach $taxa (@taxa)
		{
		print OUT1 "$taxa\n";
		#print OUT2 "$taxa 1 $taxa\n";	# species list is only for relaxed subsets. since we run mpest on relaxed subsets.
		}
	}
	$i++; # counter for subsets
	      #}

	 close(OUT);
	}


#now finding the induced subtrees by the subsets the input files

print "\n inputFile: $inFile";
print "\n number of subsets: $n_subsets";

for ($i = 1; $i <= $n_subsets; $i++)
	{
		#print "working on $i\n";
		$subset_File_s = "$outdir/size-$max_subset_size.strict.subsets.$i";  # strict
		$subset_File_r = "$outdir/size-$max_subset_size.relaxed.subsets.$i"; # relaxed
		if (is_present(\@methods, "phylonet-exact") == 1){`python $perl_scripts/induced_subtree_from_taxa.py $inFile $subset_File_s`;}

# else dieo kora jai. karon ekmatro exact er khetrei strict dorkar
		if ((is_present(\@methods, "mpest") == 1)||(is_present(\@methods, "phylonet-heu") == 1)){`python $perl_scripts/induced_subtree_from_taxa.py $inFile $subset_File_r`;}
		#last;
	}


# create a directory for phylonet, mpest etc in the same level where the input gene trees are
my $dir;
my $inFile_name;
if ($inFile =~ /(.*)\/(.*)/)
	{
		$dir = $1;   # getting the directory where the input gene trees are. I will save the pruned file in the same directory
		$inFile_name = $2; #getting the file name
		print "$1 and $2\n";
		print "\n here is dir: $dir";
	}

# creating directories

$phylo_dir = "$dir/../phylonet";  # going back one level

$condor_log = "$dir/../logs";  # going back one level

$condor= "$dir/../condor"; 


for each $method(@methods){
	$mdir = "$dir/../$method";
	`mkdir $mdir` if not -e $mdir;
}

#if ((is_present(\@methods, "phylonet-exact") == 1)||(is_present(\@methods, "phylonet-heu") == 1)){`mkdir $phylo_dir` if not -e $phylo_dir;}

`mkdir $condor_log` if not -e $condor_log;
`mkdir $condor` if not -e $condor;

########################################################################
#creating the condor files

my $condor_string = "+Group = \"GRAD\"
+Project = \"COMPUTATIONAL_BIOLOGY\"
+ProjectDescription = \"dcm-sptree\"

Universe = vanilla";

if ((is_present(\@methods, "phylonet-exact") == 1)||(is_present(\@methods, "phylonet-heu") == 1)){

my $condor_phylo = "$condor/size-$max_subset_size.condor.phylonet";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = $phylonet/phylonet_v2_4.jar\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.phylonet.log
getEnv=True
initialdir = $phylo_dir\n\n";

for ($i = 1; $i <= $n_subsets; $i++)
{

 #print OUT "Arguments = infer_st -m MDC -x -i $dir/$inFile_name.size-$max_subset_size.strict.subsets.$i -o $phylo_dir/size-$max_subset_size.subsets.$i.tre
print OUT "Arguments = infer_st -m MDC -i $dir/$inFile_name.size-$max_subset_size.relaxed.subsets.$i -o $phylo_dir/size-$max_subset_size.subsets.$i.tre

 Error=$condor_log/size-$max_subset_size.phylonet.subsets.$i.err
 Output=$condor_log/size-$max_subset_size.phylonet.subsets.$i.out
 Queue\n\n";

}


#creating the condor files for merging trees for phylonet
$condor_phylo = "$condor/size-$max_subset_size.condor.merge.phylonet";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/perl\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.merge.phylonet.log
getEnv=True
initialdir = $phylo_dir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/dcm-sptree/merge-tree.pl -dir $phylo_dir -prefix size-$max_subset_size.subsets -n $n_subsets -o $phylo_dir/all_trees_size-$max_subset_size
 Error=$condor_log/size-$max_subset_size.merge.phylonet.err
 Output=$condor_log/size-$max_subset_size.merge.phylonet.out
 Queue\n\n";

close(OUT);

#################################### RUNNING SUPERFINE ####################################################
# condor_files for running superfine with MRP on phylonet trees
$condor_phylo = "$condor/size-$max_subset_size.condor.superfine.phylonet";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.superfine.phylonet.log
getEnv=True
initialdir = $phylo_dir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/runReup.py -r gmrp $phylo_dir/all_trees_size-$max_subset_size -o $phylo_dir/size-$max_subset_size.superfine 
 Error=$condor_log/size-$max_subset_size.superfine.phylonet.err
 Output=$condor_log/size-$max_subset_size.superfine.phylonet.out
 Queue\n\n";

close(OUT);

######################################## ARBITRARY RESOLVING THE SUPERFINE OUTPUT #########################

# phylonet 
$condor_phylo = "$condor/size-$max_subset_size.condor.resolve_superfine.phylonet";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.resolve_superfine.phylonet.log
getEnv=True
initialdir = $phylo_dir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/arb_resolve_polytomies_new.py $phylo_dir/size-$max_subset_size.superfine 
 Error=$condor_log/size-$max_subset_size.resolve_superfine.phylonet.err
 Output=$condor_log/size-$max_subset_size.resolve_superfine.phylonet.out
 Queue\n\n";

close(OUT);


########## MERGING WITH MRP -- PHYLONET TREES ############################
$condor_phylo = "$condor/size-$max_subset_size.condor.mrp_merge.phylonet";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.mrp_merge.phylonet.log
getEnv=True
initialdir = $phylo_dir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/runWMRP_nam.py -i $phylo_dir/all_trees_size-$max_subset_size -o $phylo_dir/size-$max_subset_size.mrp -d $phylo_dir -r true
 Error=$condor_log/size-$max_subset_size.mrp_merge.phylonet.err
 Output=$condor_log/size-$max_subset_size.mrp_merge.phylonet.out
 Queue\n\n";

close(OUT);

########## MERGING WITH GREEDY -- PHYLONET TREES ############################

$condor_phylo = "$condor/size-$max_subset_size.condor.greedy_merge.phylonet";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /projects/sate8/bayzid-siavash-results/global/src/shell/greedy\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.greedy_merge.phylonet.log
getEnv=True
initialdir = $phylo_dir\n\n";

 print OUT "Arguments = $phylo_dir/all_trees_size-$max_subset_size 0 $phylo_dir/size-$max_subset_size.greedy
 Error=$condor_log/size-$max_subset_size.greedy_merge.phylonet.err
 Output=$condor_log/size-$max_subset_size.greedy_merge.phylonet.out
 Queue\n\n";

close(OUT);

} # end IF

###############################################################  END of PHYLONET ######################################################

# condor for mpest

#first get the set of taxa.
#my $species_list = "$dir/../specieslist";
#`perl $perl_scripts/get_taxa.pl -i $gdtree -o $species_list`;

if (is_present(\@methods, "mpest") == 1){

$mpest_dir = "$dir/../mpest";
`mkdir $mpest_dir` if not -e $mpest_dir;


my $condor_mpest = "$condor/size-$max_subset_size.condor.mpest";
open(OUT, ">", $condor_mpest) or die "can't open $condor_mpest: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /projects/sate8/bayzid-siavash-results/global/src/shell/mpest\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.mpest.log
getEnv=True
initialdir = $mpest_dir\n\n";

for ($i = 1; $i <= $n_subsets; $i++)
{
 my $species_list = "$dir/../size-$max_subset_size.specieslist.$i";
 print OUT "Arguments = $dir/$inFile_name.size-$max_subset_size.relaxed.subsets.$i $species_list $mpest_dir/size-$max_subset_size.subsets.$i.tre
 Error=$condor_log/size-$max_subset_size.mpest.subsets.$i.err
 Output=$condor_log/size-$max_subset_size.mpest.subsets.$i.out
 Queue\n\n";

}


#creating the condor files for merging trees for MP-EST
$condor_mpest = "$condor/size-$max_subset_size.condor.merge.mpest";
open(OUT, ">", $condor_mpest) or die "can't open $condor_mpest: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/perl\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.merge.mpest.log
getEnv=True
initialdir = $mpest_dir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/dcm-sptree/merge-tree.pl -dir $mpest_dir -prefix $inFile_name.size-$max_subset_size.relaxed.subsets -n $n_subsets -o $mpest_dir/all_trees_size-$max_subset_size
 Error=$condor_log/size-$max_subset_size.merge.mpest.err
 Output=$condor_log/size-$max_subset_size.merge.mpest.out
 Queue\n\n";

close(OUT);



# condor_files for running superfine with MRP on mpest trees
$condor_mpest = "$condor/size-$max_subset_size.condor.superfine.mpest";
open(OUT, ">", $condor_mpest) or die "can't open $condor_mpest: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.superfine.mpest.log
getEnv=True
initialdir = $mpest_dir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/runReup.py -r gmrp $mpest_dir/all_trees_size-$max_subset_size -o $mpest_dir/size-$max_subset_size.superfine 
 Error=$condor_log/size-$max_subset_size.superfine.mpest.err
 Output=$condor_log/size-$max_subset_size.superfine.mpest.out
 Queue\n\n";

close(OUT);


# arbitrarily resolving the superfine output

# mpest 
$condor_mpest = "$condor/size-$max_subset_size.condor.resolve_superfine.mpest";
open(OUT, ">", $condor_mpest) or die "can't open $condor_mpest: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.resolve_superfine.mpest.log
getEnv=True
initialdir = $mpest_dir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/arb_resolve_polytomies_new.py $mpest_dir/size-$max_subset_size.superfine 
 Error=$condor_log/size-$max_subset_size.resolve_superfine.mpest.err
 Output=$condor_log/size-$max_subset_size.resolve_superfine.mpest.out
 Queue\n\n";

close(OUT);


#####################33# condor for mrp and greedy consensus


########## MERGING WITH MRP -- MPEST TREES ############################
$condor_mpest = "$condor/size-$max_subset_size.condor.mrp_merge.mpest";
open(OUT, ">", $condor_mpest) or die "can't open $condor_mpest: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.mrp_merge.mpest.log
getEnv=True
initialdir = $mpest_dir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/runWMRP_nam.py -i $mpest_dir/all_trees_size-$max_subset_size -o $mpest_dir/size-$max_subset_size.mrp -d $mpest_dir -r true
 Error=$condor_log/size-$max_subset_size.mrp_merge.mpest.err
 Output=$condor_log/size-$max_subset_size.mrp_merge.mpest.out
 Queue\n\n";

close(OUT);



########## MERGING WITH GREEDY -- MPEST TREES ############################

$condor_mpest = "$condor/size-$max_subset_size.condor.greedy_merge.mpest";
open(OUT, ">", $condor_mpest) or die "can't open $condor_mpest: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /projects/sate8/bayzid-siavash-results/global/src/shell/greedy\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.greedy_merge.mpest.log
getEnv=True
initialdir = $mpest_dir\n\n";

 print OUT "Arguments = $mpest_dir/all_trees_size-$max_subset_size 0 $mpest_dir/size-$max_subset_size.greedy
 Error=$condor_log/size-$max_subset_size.greedy_merge.mpest.err
 Output=$condor_log/size-$max_subset_size.greedy_merge.mpest.out
 Queue\n\n";

close(OUT);

} #  END OF IF. THIS CHECKS WHEHTER MPEST IS GIVEN AS A METHOD IN THE INPUT

####################################################################### CREATING THE DAGFILES  ##############################

# dagfile for phylonet

if ((is_present(\@methods, "phylonet-exact") == 1)||(is_present(\@methods, "phylonet-heu") == 1)){

my $dag_phylo = "$condor/size-$max_subset_size.dagfile.phylonet";
open(OUT, ">", $dag_phylo) or die "can't open $dag_phylo: $!";


#size-14.condor.merge.phylonet   size-14.condor.superfine.mpest  size-14.condor.phylonet
print OUT "JOB  runPhylo  size-$max_subset_size.condor.phylonet
JOB  mergePhylo size-$max_subset_size.condor.merge.phylonet
JOB  superfinePhylo size-$max_subset_size.condor.superfine.phylonet
JOB  superfineResolve size-$max_subset_size.condor.resolve_superfine.phylonet
JOB  mrpMerge size-$max_subset_size.condor.mrp_merge.phylonet
JOB  greedyMerge size-$max_subset_size.condor.greedy_merge.phylonet
PARENT runPhylo CHILD mergePhylo
PARENT mergePhylo CHILD superfinePhylo
PARENT superfinePhylo CHILD superfineResolve
PARENT mergePhylo CHILD mrpMerge
PARENT mergePhylo CHILD greedyMerge";

close(OUT);

}

# dagfile for mpest
if (is_present(\@methods, "mpest") == 1){

my $dag_mpest = "$condor/size-$max_subset_size.dagfile.mpest";
open(OUT, ">", $dag_mpest) or die "can't open $dag_mpest: $!";

#size-14.condor.merge.phylonet   size-14.condor.superfine.mpest  size-14.condor.phylonet
print OUT "JOB  runMPEST  size-$max_subset_size.condor.mpest
JOB  mergeMPEST size-$max_subset_size.condor.merge.mpest
JOB  superfineMPEST size-$max_subset_size.condor.superfine.mpest
JOB  superfineResolve size-$max_subset_size.condor.resolve_superfine.mpest
JOB  mrpMerge size-$max_subset_size.condor.mrp_merge.mpest
JOB  greedyMerge size-$max_subset_size.condor.greedy_merge.mpest
PARENT runMPEST CHILD mergeMPEST
PARENT mergeMPEST CHILD superfineMPEST
PARENT superfineMPEST CHILD superfineResolve
PARENT mergeMPEST CHILD mrpMerge
PARENT mergeMPEST CHILD greedyMerge";


close(OUT);

} # END IF
#=cut
# searches if the word is present in the tokens
#$find = is_present(\@tokens1, $token);
sub is_present {
	my ($token_ref, $word) = @_ ;
	my @tokens = @{$token_ref};
	
	my $flag = 0;
	foreach $t (@tokens)
	{
		if ($t eq $word) {$flag = 1; return $flag;}		
	}		
	
return $flag;

}

print "done.\n";
