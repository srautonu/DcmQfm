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
	-dir=<input directory of the files to be merged>
	-prefix=<prefix of the file names>
	-n=<number of files to be merged>
	-itr=<which iteration>
	-flag=<1 for mpest; 0 for others>
	-o=<outputFile..GIVE FULL PATH>";
  print STDERR $message;
  die "\n";
}

GetOptions(
	"dir=s"=>\my $dir,
	"prefix=s"=>\my $prefix,
	"n=s"=>\my $n,
	"itr=s"=>\my $whichItr,
	"flag=s"=>\my $flag,
	"o=s"=>\my $outFile,
);

badInput() if not defined $dir;
badInput() if not defined $prefix;
badInput() if not defined $n;
badInput() if not defined $outFile;


open(OUT, ">", $outFile) or die "can't open $outFile: $!";

print "\n\n i am here $flag";

my $file;
for ($i = 1; $i <=$n; $i++)
	{
	
 	 if ($flag == 1) # flag 1 means mpest
		{
			if ($whichItr == 1){$file = "$dir/$prefix.$i.itr$whichItr.tre";}
			else{$file = "$dir/$prefix.$i.mpest.itr$whichItr.tre";}
		}
	 else {$file = "$dir/$prefix.$i.tre";}  # this is for phylonet
	open(INFO, $file);		# Open the file
	my @lines = <INFO>;		# Read it into an array
	close(INFO);
	
	print OUT"@lines";
	}

close(OUT);

open(INFO, $outFile);		# Open the file
my @lines = <INFO>;		# Read it into an array
close(INFO);

open(OUT, ">", $outFile) or die "can't open $outFile: $!";

#$tree_contents =~ s/:(\d+(\.\d+)?(e-\d+)?)//g;
foreach my $line (@lines)
{
	$line =~ s/:(\d+(\.\d+)?(e-\d+)?)//g;
	$line =~ s/;(.*)/;/g; # 
	print OUT "$line";
}

#print "done.\n";
