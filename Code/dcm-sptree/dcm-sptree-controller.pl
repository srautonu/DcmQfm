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
	-ps=<padding size: this is required for dactal based decomposition; if must have to give this no matter you use dactal or adaptive. this is just a bug of my implementation.>
	-od=<output dir. the initial input gene trees are kept here>
	-outgrp=<outgroups>
	-infile=<input gene trees. give full path. pruned gene trees will be created in this directory>
	-method=<set of methods you like to run. Example: -method \"phylonet-exact mpest\". IF YOUR METHOD CONTAINS PHYLONET-EXACT, YOU MUST HAVE TO DEFINE THE -strict option>
	-strict=<keeps the subsetsize strictly below (or equal) the maximum subsetsize. otherwise it can be little bit higher for some subsets. if you will run Phylonet-exact, you must have to use strict. Actually, this option will create two sets of subsets. One set is strict and another one is relaxed (for the methods that do not have the restriction as Phylo-exact). MP-EST will be using the relaxed set of subsets. if this option is not defined, only the relaxed set of subsets will be created>
	-padding=<if defined, it will add the outgroup to each subsets. otherwise it will not force the outgroup to be present in each subsets>
	-itr=<number of iteration.default is 1>";
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
	"itr=i"=>\my $itr,
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

#print "\n here is the outgroup $outgrp\n";
my @outgroups = split(/ /, $outgrp); # set of outgroups
my @methods = split(/ /, $methods); # set of outgroups

#badInput() if (($find = is_present(\@methods, "phylonet-exact")) && not defined $strict);
badInput() if ((is_present(\@methods, "phylonet-exact") == 1) && (not defined $strict));  # phylonet-exact but no -strict option is not acceptable

$itr = defined($itr) ? $itr : 1; # the default itr is one


my $dcm_sptree_script = "/u/bayzid/Research/simulation_study/tools/run_scripts/dcm-sptree";

for ($r = 1; $r <=$itr; $r++){

	$itr_dir = "$outdir/../itr$r";
	`mkdir $itr_dir` if not -e $itr_dir;

	$reps_dir = "$itr_dir/Reps";
	`mkdir $reps_dir` if not -e $reps_dir;

# find the name of the $inFile
	my $inFileName;
	my $dir;
 	if ($inFile =~ /(.*)\/(.*)/)
	{
		$inFileName = $2; 
		$dir = $1;
	}
        `ln -s $inFile $reps_dir/`;  # creating the symlink for infile. the subset of this infile will be created here

#### condor
	$condor= "$dir/../condor";
	$condor_log = "$dir/../logs";
	`mkdir $condor_log` if not -e $condor_log;
	`mkdir $condor` if not -e $condor;

	#print "\n here is the dir: $dir";
	my $condor_string = "+Group = \"GRAD\"
+Project = \"COMPUTATIONAL_BIOLOGY\"
+ProjectDescription = \"dcm-sptree\"

Universe = vanilla";

	# now calling the dcm-sptree.pl file

	if ($r == 1){
	print "\n I am inside the if";
		if (defined ($strict))
		{
		`perl $dcm_sptree_script/decomposition.pl -gdt $gdtree -od $reps_dir -dcm $decomp_type -ms $max_subset_size -ps $padding_size -outgrp "$outgrp" -infile $reps_dir/$inFileName -method "$methods" -whichItr $r -strict`;
		}
		else 
		{
		`perl $dcm_sptree_script/decomposition.pl -gdt $gdtree -od $reps_dir -dcm $decomp_type -ms $max_subset_size -ps $padding_size -outgrp "$outgrp" -infile $reps_dir/$inFileName -method "$methods" -whichItr $r`;
		}
		
        }

	else{  # creating condor file to call decomposition
		print "\n I am inside the else";
		for $method(@methods)
		{
		my $condor_decomp = "$condor/size-$max_subset_size.condor.decomp.$method.itr$r";
		open(OUT, ">", $condor_decomp) or die "can't open $condor_decomp: $!";

	
		print OUT "$condor_string";
	
		print OUT "\n\nexecutable = /lusr/bin/perl\n\n";

		print OUT "Log = $condor_log/size-$max_subset_size.decomposition.$method.log.itr$r
getEnv=True\n\n";
		$prev = $r -1;
		$newgdtree =  "$dir/../itr$prev/$method/size-$max_subset_size.superfine-mrl";
		#$newgdtree =  "$dir/../itr$prev/$method/size-$max_subset_size.superfine-mrl.resolved";
	
		if (defined ($strict))
		{
		print OUT "Arguments = $dcm_sptree_script/decomposition.pl -gdt $newgdtree -od $reps_dir -dcm $decomp_type -ms $max_subset_size -ps $padding_size -outgrp \\\"$outgrp\\\" -infile $reps_dir/$inFileName -method \\\"$method\\\" -whichItr $r -strict
 Error=$condor_log/size-$max_subset_size.decomposition.$method.err.itr$r
 Output=$condor_log/size-$max_subset_size.decomposition.$method.out.itr$r
 Queue\n\n";
		}
		else
		{
		print OUT "Arguments = $dcm_sptree_script/decomposition.pl -gdt $newgdtree -od $reps_dir -dcm $decomp_type -ms $max_subset_size -ps $padding_size -outgrp \\\"$outgrp\\\" -infile $reps_dir/$inFileName -method \\\"$method\\\" -whichItr $r
 Error=$condor_log/size-$max_subset_size.decomposition.$method.err.itr$r
 Output=$condor_log/size-$max_subset_size.decomposition.$method.out.itr$r
 Queue\n\n";
		}

close(OUT);
		} # end for

	} #end else
	

print "\n here I am before the dcm_sptree";
	if ($r == 1){
		if (defined ($strict))
		{
		`perl $dcm_sptree_script/dcm-sptree.pl -gdt $gdtree -od $reps_dir -dcm $decomp_type -ms $max_subset_size -ps $padding_size -outgrp "$outgrp" -infile $reps_dir/$inFileName -method "$methods" -whichItr $r -strict`;
		}   # look, here I sent $methods but for r>1 I sent $method (no s). also look at the difference between gdtree and newgdtree

		else
		{
			`perl $dcm_sptree_script/dcm-sptree.pl -gdt $gdtree -od $reps_dir -dcm $decomp_type -ms $max_subset_size -ps $padding_size -outgrp "$outgrp" -infile $reps_dir/$inFileName -method "$methods" -whichItr $r`;
		}
	} #end if
	else{
	
		for $method(@methods)
		{
			$prev = $r -1;
			$newgdtree =  "$dir/../itr$prev/$method/size-$max_subset_size.superfine-mrl";
			#$newgdtree =  "$dir/../itr$prev/$method/size-$max_subset_size.superfine-mrl.resolved";

			my $condor_dcm_sptree = "$condor/size-$max_subset_size.condor.dcm_sptree.$method.itr$r";
			open(OUT, ">", $condor_dcm_sptree) or die "can't open $condor_dcm_sptree: $!";

		
			print OUT "$condor_string";
	
			print OUT "\n\nexecutable = /lusr/bin/perl\n\n";

			print OUT "Log = $condor_log/size-$max_subset_size.dcm_sptree.$method.log.itr$r
getEnv=True\n\n";

		if (defined ($strict))
		{
		print OUT "Arguments = $dcm_sptree_script/dcm-sptree.pl -gdt $newgdtree -od $reps_dir -dcm $decomp_type -ms $max_subset_size -ps $padding_size -outgrp \\\"$outgrp\\\" -infile $reps_dir/$inFileName -method \\\"$method\\\" -whichItr $r -strict
 Error=$condor_log/size-$max_subset_size.dcm_sptree.$method.err.itr$r
 Output=$condor_log/size-$max_subset_size.dcm_sptree.$method.out.itr$r
 Queue\n\n";
		}
		else
		{
		print OUT "Arguments = $dcm_sptree_script/dcm-sptree.pl -gdt $newgdtree -od $reps_dir -dcm $decomp_type -ms $max_subset_size -ps $padding_size -outgrp \\\"$outgrp\\\" -infile $reps_dir/$inFileName -method \\\"$method\\\" -whichItr $r
 Error=$condor_log/size-$max_subset_size.dcm_sptree.$method.err.itr$r
 Output=$condor_log/size-$max_subset_size.dcm_sptree.$method.out.itr$r
 Queue\n\n";
		}

	close(OUT);

#creating the dag files

	my $dag_preprocess = "$condor/size-$max_subset_size.dagfile.preprocess.$method.itr$r";
	open(OUT, ">", $dag_preprocess) or die "can't open $dag_preprocess: $!";


	print OUT "JOB  rundecomp  size-$max_subset_size.condor.decomp.$method.itr$r
JOB  runsptree size-$max_subset_size.condor.dcm_sptree.$method.itr$r
PARENT rundecomp CHILD runsptree";
close(OUT);

	} #end for	


     } # end else

}



=st

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

$splist_dir = "$outdir/../splist-mpest";
`mkdir $splist_dir` if not -e $splist_dir;

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
	my $specieslist = "$splist_dir/size-$max_subset_size.specieslist.$i";
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

#$phylo_dir = "$dir/../phylonet";  # going back one level

$condor_log = "$dir/../logs";  # going back one level

$condor= "$dir/../condor"; 


foreach $method(@methods){
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

#if ((is_present(\@methods, "phylonet-exact") == 1)||(is_present(\@methods, "phylonet-heu") == 1)){

####################################################### PHYLONET-EXACT #####################

if ((is_present(\@methods, "phylonet-exact") == 1)){

$mdir = "$dir/../phylonet-exact";
my $condor_phylo = "$condor/size-$max_subset_size.condor.phylonet.x";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = $phylonet/phylonet_v2_4.jar\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.phylonet.x.log
getEnv=True
initialdir = $mdir\n\n";

for ($i = 1; $i <= $n_subsets; $i++)
{

 print OUT "Arguments = infer_st -m MDC -x -i $dir/$inFile_name.size-$max_subset_size.strict.subsets.$i -o $mdir/size-$max_subset_size.subsets.$i.tre

 Error=$condor_log/size-$max_subset_size.phylonet.x.subsets.$i.err
 Output=$condor_log/size-$max_subset_size.phylonet.x.subsets.$i.out
 Queue\n\n";

}


#creating the condor files for merging trees for phylonet
$condor_phylo = "$condor/size-$max_subset_size.condor.merge.phylonet.x";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/perl\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.merge.phylonet.x.log
getEnv=True
initialdir = $mdir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/dcm-sptree/merge-tree.pl -dir $mdir -prefix size-$max_subset_size.subsets -n $n_subsets -o $mdir/all_trees_size-$max_subset_size
 Error=$condor_log/size-$max_subset_size.merge.phylonet.x.err
 Output=$condor_log/size-$max_subset_size.merge.phylonet.x.out
 Queue\n\n";

close(OUT);

#################################### RUNNING SUPERFINE ####################################################
# condor_files for running superfine with MRP on phylonet trees
$condor_phylo = "$condor/size-$max_subset_size.condor.superfine-mrp.phylonet.x";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.superfine-mrp.phylonet.x.log
getEnv=True
initialdir = $mdir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/runReup.py -r gmrp $mdir/all_trees_size-$max_subset_size -o $mdir/size-$max_subset_size.superfine-mrp 
 Error=$condor_log/size-$max_subset_size.superfine-mrp.phylonet.x.err
 Output=$condor_log/size-$max_subset_size.superfine-mrp.phylonet.x.out
 Queue\n\n";

close(OUT);

# superfine with mrl
$condor_phylo = "$condor/size-$max_subset_size.condor.superfine-mrl.phylonet.x";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.superfine-mrl.phylonet.x.log
getEnv=True
initialdir = $mdir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/runReup.py -r rml $mdir/all_trees_size-$max_subset_size -o $mdir/size-$max_subset_size.superfine-mrl
 Error=$condor_log/size-$max_subset_size.superfine-mrl.phylonet.x.err
 Output=$condor_log/size-$max_subset_size.superfine-mrl.phylonet.x.out
 Queue\n\n";

close(OUT);

######################################## ARBITRARY RESOLVING THE SUPERFINE OUTPUT #########################

#resolving superfine with mrp
$condor_phylo = "$condor/size-$max_subset_size.condor.resolve_superfine-mrp.phylonet.x";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.resolve_superfine-mrp.phylonet.x.log
getEnv=True
initialdir = $mdir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/arb_resolve_polytomies_new.py $mdir/size-$max_subset_size.superfine-mrp 
 Error=$condor_log/size-$max_subset_size.resolve_superfine-mrp.phylonet.x.err
 Output=$condor_log/size-$max_subset_size.resolve_superfine-mrp.phylonet.x.out
 Queue\n\n";

close(OUT);



#resolving superfine with mrl
$condor_phylo = "$condor/size-$max_subset_size.condor.resolve_superfine-mrl.phylonet.x";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.resolve_superfine-mrl.phylonet.x.log
getEnv=True
initialdir = $mdir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/arb_resolve_polytomies_new.py $mdir/size-$max_subset_size.superfine-mrl 
 Error=$condor_log/size-$max_subset_size.resolve_superfine-mrl.phylonet.x.err
 Output=$condor_log/size-$max_subset_size.resolve_superfine-mrl.phylonet.x.out
 Queue\n\n";

close(OUT);

########## MERGING WITH MRP -- PHYLONET TREES ############################

########## MERGING WITH GREEDY -- PHYLONET TREES ############################

$condor_phylo = "$condor/size-$max_subset_size.condor.greedy_merge.phylonet.x";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /projects/sate8/bayzid-siavash-results/global/src/shell/greedy\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.greedy_merge.phylonet.x.log
getEnv=True
initialdir = $mdir\n\n";

 print OUT "Arguments = $mdir/all_trees_size-$max_subset_size 0 $mdir/size-$max_subset_size.greedy
 Error=$condor_log/size-$max_subset_size.greedy_merge.phylonet.x.err
 Output=$condor_log/size-$max_subset_size.greedy_merge.phylonet.x.out
 Queue\n\n";

close(OUT);

} # end IF

###############################################################  END of PHYLONET-EXACT ######################################################

# NOW PHYLONET-HEURISTIC

if ((is_present(\@methods, "phylonet-heu") == 1)){

$mdir = "$dir/../phylonet-heu";
my $condor_phylo = "$condor/size-$max_subset_size.condor.phylonet.h";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = $phylonet/phylonet_v2_4.jar\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.phylonet.h.log
getEnv=True
initialdir = $mdir\n\n";

for ($i = 1; $i <= $n_subsets; $i++)
{

print OUT "Arguments = infer_st -m MDC -i $dir/$inFile_name.size-$max_subset_size.relaxed.subsets.$i -o $mdir/size-$max_subset_size.subsets.$i.tre

 Error=$condor_log/size-$max_subset_size.phylonet.h.subsets.$i.err
 Output=$condor_log/size-$max_subset_size.phylonet.h.subsets.$i.out
 Queue\n\n";

}


#creating the condor files for merging trees for phylonet
$condor_phylo = "$condor/size-$max_subset_size.condor.merge.phylonet.h";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/perl\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.merge.phylonet.h.log
getEnv=True
initialdir = $mdir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/dcm-sptree/merge-tree.pl -dir $mdir -prefix size-$max_subset_size.subsets -n $n_subsets -o $mdir/all_trees_size-$max_subset_size
 Error=$condor_log/size-$max_subset_size.merge.phylonet.h.err
 Output=$condor_log/size-$max_subset_size.merge.phylonet.h.out
 Queue\n\n";

close(OUT);

#################################### RUNNING SUPERFINE ####################################################
# condor_files for running superfine with MRP on phylonet trees
$condor_phylo = "$condor/size-$max_subset_size.condor.superfine-mrp.phylonet.h";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.superfine-mrp.phylonet.h.log
getEnv=True
initialdir = $mdir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/runReup.py -r gmrp $mdir/all_trees_size-$max_subset_size -o $mdir/size-$max_subset_size.superfine-mrp
 Error=$condor_log/size-$max_subset_size.superfine-mrp.phylonet.h.err
 Output=$condor_log/size-$max_subset_size.superfine-mrp.phylonet.h.out
 Queue\n\n";

close(OUT);

# superfine with mrl
$condor_phylo = "$condor/size-$max_subset_size.condor.superfine-mrl.phylonet.h";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.superfine-mrl.phylonet.h.log
getEnv=True
initialdir = $mdir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/runReup.py -r rml $mdir/all_trees_size-$max_subset_size -o $mdir/size-$max_subset_size.superfine-mrl
 Error=$condor_log/size-$max_subset_size.superfine-mrl.phylonet.h.err
 Output=$condor_log/size-$max_subset_size.superfine-mrl.phylonet.h.out
 Queue\n\n";

close(OUT);

######################################## ARBITRARY RESOLVING THE SUPERFINE OUTPUT #########################

# arbitrarily resolving superfine with mrp 
$condor_phylo = "$condor/size-$max_subset_size.condor.resolve_superfine-mrp.phylonet.h";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.resolve_superfine-mrp.phylonet.h.log
getEnv=True
initialdir = $mdir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/arb_resolve_polytomies_new.py $mdir/size-$max_subset_size.superfine-mrp 
 Error=$condor_log/size-$max_subset_size.resolve_superfine-mrp.phylonet.h.err
 Output=$condor_log/size-$max_subset_size.resolve_superfine-mrp.phylonet.h.out
 Queue\n\n";

close(OUT);


#arbitrarily resolving superfine with mrl
$condor_phylo = "$condor/size-$max_subset_size.condor.resolve_superfine-mrl.phylonet.h";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.resolve_superfine-mrl.phylonet.h.log
getEnv=True
initialdir = $mdir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/arb_resolve_polytomies_new.py $mdir/size-$max_subset_size.superfine-mrl 
 Error=$condor_log/size-$max_subset_size.resolve_superfine-mrl.phylonet.h.err
 Output=$condor_log/size-$max_subset_size.resolve_superfine-mrl.phylonet.h.out
 Queue\n\n";

close(OUT);

########## MERGING WITH MRP -- PHYLONET TREES ############################

########## MERGING WITH GREEDY -- PHYLONET TREES ############################

$condor_phylo = "$condor/size-$max_subset_size.condor.greedy_merge.phylonet.h";
open(OUT, ">", $condor_phylo) or die "can't open $condor_phylo: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /projects/sate8/bayzid-siavash-results/global/src/shell/greedy\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.greedy_merge.phylonet.h.log
getEnv=True
initialdir = $mdir\n\n";

 print OUT "Arguments = $mdir/all_trees_size-$max_subset_size 0 $mdir/size-$max_subset_size.greedy
 Error=$condor_log/size-$max_subset_size.greedy_merge.phylonet.h.err
 Output=$condor_log/size-$max_subset_size.greedy_merge.phylonet.h.out
 Queue\n\n";

close(OUT);

} # end IF





########################################################################################33
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
 my $species_list = "$splist_dir/size-$max_subset_size.specieslist.$i";
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
$condor_mpest = "$condor/size-$max_subset_size.condor.superfine-mrp.mpest";
open(OUT, ">", $condor_mpest) or die "can't open $condor_mpest: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.superfine-mrp.mpest.log
getEnv=True
initialdir = $mpest_dir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/runReup.py -r gmrp $mpest_dir/all_trees_size-$max_subset_size -o $mpest_dir/size-$max_subset_size.superfine-mrp 
 Error=$condor_log/size-$max_subset_size.superfine-mrp.mpest.err
 Output=$condor_log/size-$max_subset_size.superfine-mrp.mpest.out
 Queue\n\n";

close(OUT);


# condor_files for running superfine with MRl on mpest trees
$condor_mpest = "$condor/size-$max_subset_size.condor.superfine-mrl.mpest";
open(OUT, ">", $condor_mpest) or die "can't open $condor_mpest: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.superfine-mrl.mpest.log
getEnv=True
initialdir = $mpest_dir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/runReup.py -r rml $mpest_dir/all_trees_size-$max_subset_size -o $mpest_dir/size-$max_subset_size.superfine-mrl 
 Error=$condor_log/size-$max_subset_size.superfine-mrl.mpest.err
 Output=$condor_log/size-$max_subset_size.superfine-mrl.mpest.out
 Queue\n\n";

close(OUT);

# arbitrarily resolving the superfine (MRP) output

# mpest 
$condor_mpest = "$condor/size-$max_subset_size.condor.resolve_superfine-mrp.mpest";
open(OUT, ">", $condor_mpest) or die "can't open $condor_mpest: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.resolve_superfine-mrp.mpest.log
getEnv=True
initialdir = $mpest_dir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/arb_resolve_polytomies_new.py $mpest_dir/size-$max_subset_size.superfine-mrp 
 Error=$condor_log/size-$max_subset_size.resolve_superfine-mrp.mpest.err
 Output=$condor_log/size-$max_subset_size.resolve_superfine-mrp.mpest.out
 Queue\n\n";

close(OUT);


# arbitrarily resolving the superfine (MRL) output

$condor_mpest = "$condor/size-$max_subset_size.condor.resolve_superfine-mrl.mpest";
open(OUT, ">", $condor_mpest) or die "can't open $condor_mpest: $!";


print OUT "$condor_string";

print OUT "\n\nexecutable = /lusr/bin/python\n\n";

print OUT "Log = $condor_log/size-$max_subset_size.resolve_superfine-mrl.mpest.log
getEnv=True
initialdir = $mpest_dir\n\n";

 print OUT "Arguments = /u/bayzid/Research/simulation_study/tools/run_scripts/arb_resolve_polytomies_new.py $mpest_dir/size-$max_subset_size.superfine-mrl 
 Error=$condor_log/size-$max_subset_size.resolve_superfine-mrl.mpest.err
 Output=$condor_log/size-$max_subset_size.resolve_superfine-mrl.mpest.out
 Queue\n\n";

close(OUT);


#####################33# condor for mrp and greedy consensus


########## MERGING WITH MRP -- MPEST TREES ############################



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

# dagfile for phylonet-exact

if ((is_present(\@methods, "phylonet-exact") == 1)){

my $dag_phylo = "$condor/size-$max_subset_size.dagfile.phylonet.x";
open(OUT, ">", $dag_phylo) or die "can't open $dag_phylo: $!";


#size-14.condor.merge.phylonet   size-14.condor.superfine.mpest  size-14.condor.phylonet
print OUT "JOB  runPhylo  size-$max_subset_size.condor.phylonet.x
JOB  mergePhylo size-$max_subset_size.condor.merge.phylonet.x
JOB  superfinePhylo-mrp size-$max_subset_size.condor.superfine-mrp.phylonet.x
JOB  superfinePhylo-mrl size-$max_subset_size.condor.superfine-mrl.phylonet.x
JOB  superfineResolve-mrp size-$max_subset_size.condor.resolve_superfine-mrp.phylonet.x
JOB  superfineResolve-mrl size-$max_subset_size.condor.resolve_superfine-mrl.phylonet.x
JOB  greedyMerge size-$max_subset_size.condor.greedy_merge.phylonet.x
PARENT runPhylo CHILD mergePhylo
PARENT mergePhylo CHILD superfinePhylo-mrp
PARENT mergePhylo CHILD superfinePhylo-mrl
PARENT superfinePhylo-mrp CHILD superfineResolve-mrp
PARENT superfinePhylo-mrl CHILD superfineResolve-mrl
PARENT mergePhylo CHILD greedyMerge";

close(OUT);

}

#dagfile for phylonet-heu
if ((is_present(\@methods, "phylonet-heu") == 1)){

my $dag_phylo = "$condor/size-$max_subset_size.dagfile.phylonet.h";
open(OUT, ">", $dag_phylo) or die "can't open $dag_phylo: $!";


#size-14.condor.merge.phylonet   size-14.condor.superfine.mpest  size-14.condor.phylonet
print OUT "JOB  runPhylo  size-$max_subset_size.condor.phylonet.h
JOB  mergePhylo size-$max_subset_size.condor.merge.phylonet.h
JOB  superfinePhylo-mrp size-$max_subset_size.condor.superfine-mrp.phylonet.h
JOB  superfinePhylo-mrl size-$max_subset_size.condor.superfine-mrl.phylonet.h
JOB  superfineResolve-mrp size-$max_subset_size.condor.resolve_superfine-mrp.phylonet.h
JOB  superfineResolve-mrl size-$max_subset_size.condor.resolve_superfine-mrl.phylonet.h
JOB  greedyMerge size-$max_subset_size.condor.greedy_merge.phylonet.h
PARENT runPhylo CHILD mergePhylo
PARENT mergePhylo CHILD superfinePhylo-mrp
PARENT mergePhylo CHILD superfinePhylo-mrl
PARENT superfinePhylo-mrp CHILD superfineResolve-mrp
PARENT superfinePhylo-mrl CHILD superfineResolve-mrl
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
JOB  superfineMPEST-mrp size-$max_subset_size.condor.superfine-mrp.mpest
JOB  superfineMPEST-mrl size-$max_subset_size.condor.superfine-mrl.mpest
JOB  superfineResolve-mrp size-$max_subset_size.condor.resolve_superfine-mrp.mpest
JOB  superfineResolve-mrl size-$max_subset_size.condor.resolve_superfine-mrl.mpest
JOB  greedyMerge size-$max_subset_size.condor.greedy_merge.mpest
PARENT runMPEST CHILD mergeMPEST
PARENT mergeMPEST CHILD superfineMPEST-mrp
PARENT mergeMPEST CHILD superfineMPEST-mrl
PARENT superfineMPEST-mrp CHILD superfineResolve-mrp
PARENT superfineMPEST-mrl CHILD superfineResolve-mrl
PARENT mergeMPEST CHILD greedyMerge";


close(OUT);

} # END IF
=cut
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
