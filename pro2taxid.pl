#!/usr/bin/perl
use strict;

use Getopt::Long;
my ($in, $out, $map, $help);
GetOptions(
	'in|i=s' => \$in,
	'out|o=s' => \$out,
	'map|m=s' => \$map,
	'help|h!' => \$help,
);
if (! $in) {
	die "Usage: pro2taxid.pl -i in.fa -o out.fa -m prot.accession2taxid";
}
print "Screen headers to reduce RAM used\n";
open I, "<", $in or die "Cannot open fasta file $in!";
my %acc2tax;
my $num;
while (<I>) {
	chomp;
	next until /^>/;
	while (/(?:>|\x01)(\w+\.\d+) /gc) {
		$acc2tax{$1} = undef;
		$num ++;
	}
}
print "Found $num accessions\n";
print "Build hash table of accnums to taxids\n";
open M, "<", $map or die "Cannot open accession2taxid file $map!";
my ($acc, $tax);
$num = 0;
scalar(<M>);
while (<M>) {
	chomp;
	(undef, $acc, $tax, undef) = split(/\t/,$_);
	if (exists $acc2tax{$acc}) {
		$acc2tax{$acc} = $tax;
		$num++;
	}
}
close M;
print "Found $num pairs of accnum-taxon\n";
print "Convert fasta headers to >accnum_taxid\n";
open O, ">", $out or die "Cannot open fasta file $out!";
seek I, 0, 0;
$num = 0;
while (<I>) {
	chomp;
	if (/^>/) {
		my @ids = ();
		my $header = '';
		while (/(?:>|\x01)(\w+\.\d+) /gc) {
			push @ids, $1;
			push @ids, $acc2tax{$1} if $acc2tax{$1};
			last;
		}
		$header = join('_',@ids);
		$num ++;
		print O ">$header\n";
	} else {
		print O "$_\n";
	}
}
close I;
close O;
print "Converted $num sequences in new fasta file $out\n";
