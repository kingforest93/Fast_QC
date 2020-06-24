#!/usr/bin/perl
use strict;
die "Usage: perl fasta_oneline.pl fastafile" if not defined $ARGV[0];
my $n;
open IN, "<", $ARGV[0] or die "Cannot open $ARGV[0]!";
print STDERR "formating multi-line to one-line ... \n";
while (<IN>) {
	chomp;
	if (/^>/) {
		$n ++;
		print STDOUT "$_\n" if $n == 1;
		print STDOUT "\n$_\n" if $n > 1;
	} else {
		print STDOUT "$_";
	}
}
print STDERR "\ndone\n";
close IN;
