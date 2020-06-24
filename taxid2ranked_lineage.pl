#!/usr/bin/perl
use strict;
die "Usage: perl taxid2ranked_lineage.pl taxid.list" if not defined $ARGV[0];
my %id_line;
my $dmp = "/public/agis/fanwei_group/wangsen/database/taxonomy/rankedlineage.dmp";
my @rank = ('d', 'k', 'p', 'c', 'o', 'f', 'g', 's', 'sp');
open IN, "<", $dmp or die "cannot find and open $dmp!";
while (<IN>) {
	chomp;
	my @t = split /\s\|\s?/, $_;
	my $i = shift @t;
	@{$id_line{$i}} = @t;
}
close IN;
if ($ARGV[0] =~ /\d+/) {
	my @t = reverse @{$id_line{$ARGV[0]}} if $id_line{$ARGV[0]};
	for (my $i = 0; $i < @t; $i ++) {
		$t[$i] = "$rank[$i]__$t[$i]";
	}
	my $t = join "|", @t;
	print "$ARGV[0]\t$t\n";
} else {
	while (<STDIN>) {
		chomp;
		my @t = reverse @{$id_line{$_}} if $id_line{$_};
		for (my $i = 0; $i < @t; $i ++) {
                	$t[$i] = "$rank[$i]__$t[$i]";
        	}
        	my $t = join "; ", @t;
		print "$_\t$t\n";
	}
}
