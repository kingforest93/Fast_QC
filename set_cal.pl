#!/usr/bin/perl

use strict;
use warnings;

my $usage = "\n no input files! \n\n Usage: perl /public/agis/fanwei_group/wangsen/code/perl_script/set_cal.pl file1 file2 ... \n\n";

if (not defined($ARGV[0])) { die $usage }
my @files = @ARGV;

my %degs;
foreach my $file (@files) {
	open(IN, "<$file") or die "cannot open $file! $!";
	while (<IN>) {
	 	chomp($_);
		$degs{$_}++; 
	}
	close IN;
}

print "Gene_ID \t Number \n";
foreach my $gene (keys %degs) {
	if ($degs{$gene} == 3) {
		print "$gene:\t$degs{$gene}\n";		
	}
}
