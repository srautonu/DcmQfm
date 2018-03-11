#!/lusr/bin/perl -w

use strict;
use warnings;
use Getopt::Long;

#input: tree with both branch lengths and support values
#)sv:br

#output: see below

sub badInput {
  my $message = "Usage: perl $0
	-i=<tree>
	-o=<output tree>";
  print STDERR $message;
  die "\n";
}

GetOptions(
	"i=s"=>\my $tree,
	"o=s"=>\my $outtree,
);

badInput() if not defined $tree;
badInput() if not defined $outtree;
#my $char = "a-zA-Z0-9.";
my $tree_contents = `cat $tree`;
#$tree_contents =~ s/\)(\d+(\.\d+)?):(\d+(\.\d+)?)/):$3/g; #):br  # this is for phylonet  # eta die edge support delet kora hoi
#$tree_contents =~ s/\)(\d+(\.\d+)?):(\d+(\.\d+)?)/)/g; #)
#$tree_contents =~ s/:(\d+(\.\d+)?)//g; #)                          # eta thaklei hoi  USED THIS TO STRIP RAXML TREES
$tree_contents =~ s/:(\d+(\.\d+)?(e-\d+)?)//g; #) (no sv)  #to handle :1.223e-05 type value that includes exponential (e)

#$tree_contents =~ s/:(-)?(\d+(\.\d+)?(E-\d+)?)//g; # for stripping beast trees  used in simulation-beast_gt_accuracy.pl
#$tree_contents =~ s/:(-)?(\d+(\.\d+)?(e-\d+)?)//g; # for stripping beast trees  used in simulation-beast_gt_accuracy.pl for pruned ekhane e chhilo

$tree_contents =~ s/;(.*)/;/g; # 

#$tree_contents =~ s/([$char])\_/$1/g;

#$tree_contents =~ s/:(-)?(\d+(\.\d+)?)//g; 

#$tree_contents =~ s/17:/O:/g;   

#$tree_contents =~ s/O/0/g;   # for Rimpi's quartets

#$tree_contents =~ s/(.*)(\.)(.*)/$2$3/g;   

#$tree_contents =~ s/0.0/0/g; # for greedy tree

#$tree_contents =~ s/;/;\n/g;
#$tree_contents =~ s/;\n/;/g;
#$tree_contents =~ s/'//g; 
#$tree_contents =~ s/;;/;/g; 
#$tree_contents =~ s/(\d+)(.)(\d+)/$1/g;   # 11-taxon er 1.1, 2.2 egulak 1, 2 etc. kora

#$tree_contents =~ s/(\d+)/S$1/g;
#$tree_contents =~ s/(\d+):/S$1:/g;
#$tree_contents =~ s/:(-)?(\d+(\.\d+)?(e-\d+)?)//g; #) # to strip branch support from *beast estimated gene trees.

#$tree_contents =~ s/(\d+)(\s)(vs.)(\s)(\d+)\n/$1 $5 /g;   # pairwise compatibility file k format kora

#$tree_contents =~ s/:(\d+(\.\d+)?)(E-\d+)?//g;
#$tree_contents =~ s/\)(\d+(\.\d+)?)/)/g; #) (no sv)       )1.344 ei type jinishgula strip korar jonno                   

#this is ugly:
#some are: taxa:br, )sv:br
#some taxa are just numbers -> ambiguity
#$tree_contents =~ s/\((.*?):(\d+(\.\d+)?)/\($1/g;
#$tree_contents =~ s/\,(.*?):(\d+(\.\d+)?)/\,$1/g;
#$tree_contents =~ s/\)(\d+(\.\d+)?)?:(\d+(\.\d+)?)/)/g;

#$tree_contents =~ s/\[(.*?)\]//g; #) THIS IS FOR STRIPPING BEAST GENERATED GENE TREES FOR INPUT TO MBSUM(BUCKY)

#$tree_contents =~ s/_(\d+(\.\d+)?)//g;  #for igtp.. PSb submission e amader simulated datasets k iGTP usable korar jonno. .forIGTP extension er files


#$tree_contents =~ s/^\s+//;

#$tree_contents =~ s/([a-z])\./$1/g;  #goloboff data er shortname korte kaje lage  eta bhul nicher ta kaje lage
#$tree_contents =~ s/(.*)____(.*)/$1/g;  #goloboff data er shortname korte -- for alignment
#$tree_contents =~ s/(.*?)____(.*?)(:)/$1:/g;  #goloboff data er shortname korte -- in tree  this makes goloboff too short to be correct.
#$tree_contents =~ s/(.*?)_@(.*?)(:)/$1:/g;  #goloboff data er shortname korte -- in tree this is correct
#$tree_contents =~ s/(>)([A-Z])(.*)/$1.$2.lc($3)/eg;   # greatly done! FOR ALIGNMENT --eta holo prothom character as it is rekhe (jeta originally capital) bakigula k lower case kora . for goloboff data

#my $char = "[]";
#$tree_contents =~ s/\[(.*?)\]//g; #) 
#$tree_contents =~ s/(\d+(\.\d+)?)/38.9*$1/ge; 
#my $char = "a-zA-Z0-9.";
#$tree_contents =~ s/(.*)([^$char]+)0/REP/g; 
#$tree_contents =~ s/&R/&U/g; 
#$tree_contents =~ s/'//g; 
#$tree_contents =~ s/\]//g; 
#$tree_contents =~ s/-//g; 
#$tree_contents =~ s/"//g; 
#$tree_contents =~ s/\n/,/g; 
#$tree_contents =~ s/\^/.CAP./g; # to change the ^ thing in goloboff dataset
#$tree_contents =~ tr/a-z/A-Z/;  # to upper case

#$tree_contents =~ s/([^\(]*)//;  # to upper case
######################### for unrooting
=st
# etar jonno nicher outtree te write er option ta off korte hobe
open(INFO, $tree);		# Open the file
my @lines = <INFO>;		# Read it into an array
close(INFO);

open(OUT, ">", $outtree) or die "can't open $outtree: $!";

my $char = "a-zA-Z0-9.";
my $FILTER = "a-zA-Z0-9";
my $ch = "(";
my $replace = "3.21971e-248"; #"8.19273e-309";
foreach my $line (@lines){
#$line =~  s/(.*)([^$char]+)0$/$1$2$replace/g; 
#$line =~ s/^\(/[&U](/g; # to introduce [&U] in the beginnig of each tree
#$line =~ s/([^$ch]+)(.*)/$2/g; # to remove texts before a tree
#$line =~ s/\)$/\);/g; # to add semicolon at the end of each line

#$line =~ s/([^\(]*)//;  # to remove the [&U] from the beginning of each of the gene trees
$line =~ s/;(.*)/;/g; # 
#$line =~ s/\*//g; # 
#$line =~ s/^\s+//;
#$line =~ s/(\d+)/S$1/g;

#$line =~ s/([^\[]*)//;
#$line =~ s/[',\[\]]//g;

#$line =~ s/\n/\)\);\n/g;
#print "\n here: $line";
#print "tree";
#$line =~ s/^([$char])/\(\($1/g; # to introduce [&U] in the beginnig of each tree
#$line =~ s/\|/\),\(/g;
#$line =~ s/\n/\)\);\n/g;
#$line =~ s/([$char])$/$1\)\);\n/g;

#$line =~ s/^\s+//;
#$line =~ s/\s+$//;
#$line =~ s/;/;\n/g; #
#print "\n here: $line";

#$line =~ s/(.*)\s+(\d+)/$1/;

#nicher dui line holo check korar jonno j line ta empty naki
my $test = $line;   
#$test =~ s/[^$FILTER]//go;

if($test){
print OUT "$line";
}
}
close(OUT);
=cut
#############################

#$tree_contents =~ s/([A-Z])(.*?)(:)/$1.lc($2).$3/eg;   # greatly done! FOR TREE WITH BRANCH LENGTH -- eta holo prothom character OF TAXA as it is rekhe (jeta originally capital) bakigula k lower case kora  . for goloboff data
#=st
open(OUT, ">", $outtree) or die "can't open $outtree: $!";
print OUT $tree_contents;
close(OUT);
#=cut
print "output at $outtree\n";
print "done.\n";
