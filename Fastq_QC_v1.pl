#!/usr/bin/perl

=head1 Name and description

Fastq_QC_v1.pl

This program read original fastq files from Illumina platforms and produce the quality reports in a new user-defined file.
It includes number of total reads, frequency of read length and duplications, distribution of A/T/C/G/N and Q-scores in each base position.

=head1 Usage

perl Fastq_QC_v1.pl -i *.fastq[.gz] -o *.qc [-h] [-v]

Makesure fastqc.perl and fastq files to check in the same director place, but this is not a must if you make fastqc.perl executable in the Bash $PATH, and 'perl' can be omitted in that case.

=head1 Author

SenWang
E-mail: wangsen1993@163.com

=head1 Update

Fastq_QC_v1.pl v 1.1, 2018/11/25
Fastq_QC_v1.pl v 1.0, 2018/11/23

=cut

use strict;
use Getopt::Long; #Pass parameters into program
use Cwd; #Capture the current working directory

#set the available parameters used in command line
my ($dir,$input,$output,$version,$help,$t_start,$t_end,$t_consum);
GetOptions(
	'input|i=s' => \$input,
	'output|o=s' => \$output,
	'version|v!' => \$version,
	'help|h!' => \$help,
);
$dir = cwd();

$t_start = localtime(time());
print "fastqc.pl starts at: $t_start\n";
$t_start = time();

#open fastq file and create output file to process
if ($input && $output) {
	open IN, "<$dir/$input" or die "Open fail: $!";
	open OUT, ">$dir/$output" or die "Create fail: $!";
}
else {
	die(`pod2text $0`);
}
print "$input is under processing, output will be in $output...\n";

#read each line from the fastq file for parsing
my $N_reads;
my (@Nbases,@Qscores);
my (%Count_seqs,%Len_seqs);
my $line = 0;
while (<IN>) {
	chomp;$line++;
	if (not($line % 2) and ($line % 4)) { #match a read line
		$N_reads++;$Count_seqs{$_}++; #count total reads and duplication time of each read
		my $l = length;$Len_seqs{"$l"}++; #count reads with the same length
		my $i = 0;
		foreach my $b (split(//, $_)) { #convert read into array for parsing
			$i++;
			$Nbases[$i]{"$b"}++; #use hash to count A|T|C|G|N in each position
		}
	}
	elsif (not($line % 4)) {		
		my $j = 0;
		foreach my $char (split(//,$_)) { #converst a Q-score line into an array for parsing			
			$j++; #base position
			my $q = ord($char) - 33; #Illumina 1.8+ Phred+33: 0 to 41
			$Qscores[$j]{"$q"}++; #use hash to count reads with the same Q-score in each position
		}
	}
}
close IN; 

print "$N_reads reads in $input have been processed\n";
print OUT "Number of reads:\t$N_reads\n"; #ouput total read number
print "start to count reads of the same length...\n";

#generate the distribution of read length
print OUT "\nRead_length\tNumber_of_reads\tPercent\n";
foreach (sort {$a <=> $b} keys %Len_seqs) {
	my $r = $Len_seqs{$_}/$N_reads*100;
	printf OUT "%11d\t%15d\t%.2f%%\n", $_,$Len_seqs{$_},$r;
}

#calculate total base number in each position
print "start to calculate the percentage of A|T|C|G|N in each base position along read...\n";
my $pos = 0;
my @N_B;
foreach (@Nbases) {
	next if (not defined($_));
	$pos++;
	foreach my $b (keys %$_) {
		$N_B[$pos] += $$_{$b};
	}	
}

#generate A|T|C|G|N percentages in each position
print OUT "\nPos_B\tNumber_of_bases\tFreq_A\tFreq_T\tFreq_C\tFreq_G\tFreq_N\n";
$pos = 0;
foreach (@Nbases) {
	next if (not defined($_));
	$pos++;my %Freq_B;	
	foreach my $b (keys %$_) {
		$$_{$b} = 0 if (not defined($$_{$b}));
		$Freq_B{$b} = $$_{$b}/$N_B[$pos]*100;
	}	
	printf OUT "%5d\t%15d\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\n",$pos,$N_B[$pos],$Freq_B{A},$Freq_B{T},$Freq_B{C},$Freq_B{G},$Freq_B{N};
}

#generate distribution of Q-scores in each position
print "start to calculate the distribution of base Q-score in each position...\n";
print OUT "\nPos_B\tNumber_of_bases\tP_Q=0\tP_Q=1\tP_Q=2\tP_Q=3\tP_Q=4\tP_Q=5\tP_Q=6\tP_Q=7\tP_Q=8\tP_Q=9\tP_Q10\tP_Q11\tP_Q12\tP_Q13\tP_Q14\tP_Q15\tP_Q16\tP_Q17\tP_Q18\tP_Q19\tP_Q20\tP_Q21\tP_Q22\tP_Q23\tP_Q24\tP_Q25\tP_Q26\tP_Q27\tP_Q28\tP_Q29\tP_Q30\tP_Q31\tP_Q32\tP_Q33\tP_Q34\tP_Q35\tP_Q36\tP_Q37\tP_Q38\tP_Q39\tP_Q40\tP_Q41\n";
$pos = 0;
foreach (@Qscores) {
	next if (not defined($_));
	$pos++;my %Freq_Q;
	foreach my $q (keys %$_) {
		$$_{$q} = 0 if (not defined($$_{$q}));
		$Freq_Q{$q} = $$_{$q}/$N_B[$pos]*100;
	}
	printf OUT "%5d\t%15d\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f%%\n",$pos,$N_B[$pos],$Freq_Q{0},$Freq_Q{1},$Freq_Q{2},$Freq_Q{3},$Freq_Q{4},$Freq_Q{5},$Freq_Q{6},$Freq_Q{7},$Freq_Q{8},$Freq_Q{9},$Freq_Q{10},$Freq_Q{11},$Freq_Q{12},$Freq_Q{13},$Freq_Q{14},$Freq_Q{15},$Freq_Q{16},$Freq_Q{17},$Freq_Q{18},$Freq_Q{19},$Freq_Q{20},$Freq_Q{21},$Freq_Q{22},$Freq_Q{23},$Freq_Q{24},$Freq_Q{25},$Freq_Q{26},$Freq_Q{27},$Freq_Q{28},$Freq_Q{29},$Freq_Q{30},$Freq_Q{31},$Freq_Q{32},$Freq_Q{33},$Freq_Q{34},$Freq_Q{35},$Freq_Q{36},$Freq_Q{37},$Freq_Q{38},$Freq_Q{39},$Freq_Q{40},$Freq_Q{41};
}

#generate read duplication time
print "start to count reads of the same occurance time...\n";
print OUT "\nDup_times\tNumber_of_reads\tPercent\n";
my %Freq_seqs;
foreach (values %Count_seqs) {
	$Freq_seqs{$_}++;
}
foreach (sort {$a <=> $b} keys %Freq_seqs) {
	my $r = $Freq_seqs{$_}/$N_reads*100;
	printf OUT "%9d\t%15d\t%.2f%%\n",$_,$Freq_seqs{$_},$r;
}
close OUT;

$t_end = localtime(time());
print "fastqc.pl ends at: $t_end\n";
$t_end = time();
$t_consum = $t_end - $t_start;
print "the current process totally takes: $t_consum s\n";
