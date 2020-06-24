#!/usr/bin/perl
use strict;

defined $ARGV[0] || die "Usage: rep_select.pl rep_seq.fna protein.faa";
open INA, "<", "$ARGV[0]" || die "Cannot open representative gene file $ARGV[0]!";
open INB, "<", "$ARGV[1]" || die "Cannot open predicted protein file $ARGV[1]!";

my %reps;
print STDERR "reading headers of representative sequences ... \n";
while (<INA>) {
	chomp;
	$reps{$1} = 1 if /^>(Contig_\d+?_\d+?)/;
}
close INA;
print STDERR "done\n";

my $h;
print STDERR "selecting the corresponding sequences with the above headers ... \n";
while (<INB>) {
	$h = $1 if /^>(Contig_\d+?_\d+?)/;
	print STDOUT "$_\n" if $reps{$h};
}
close INB;
print STDERR "done\n";
