#!/usr/bin/perl
use strict;

defined $ARGV[0] || die "Usage: format_fasta.pl input.fa";
open IN, "<", $ARGV[0] || die "Cannot open file $ARGV[0]!";
my ($id, $num);
my %seqs;
while (<IN>) {
	chomp;
	if (/^>(\w+) /) {
		$id =$1;
#		print ++$num . "sequences\r";
	} else {
		s/\*//g;
		$seqs{$id} .= $_;
	}
}
close(IN);
foreach $id (sort keys %seqs) {
	print ">$id\n$seqs{$id}\n";
}
