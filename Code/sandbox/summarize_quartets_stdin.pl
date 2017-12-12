# Author: Md. Shamsuzzoha Bayzid
# Sep 05, 2014

#use strict;
use warnings;
use Getopt::Long;

   
my %count;

 while (my $line = <STDIN>) {
  
		 chomp $line;
		$count{$line}++;
	}

 foreach my $line (sort keys %count) {
    print "$line $count{$line}";
    print "\n";
	}

