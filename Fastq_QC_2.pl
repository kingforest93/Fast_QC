#!/usr/bin/perl

=head1 Name and description

Fast_QC_2.pl

This program read original fastq files from Illumina platforms and produce the quality reports in a new user-defined file.
It includes number of total reads, frequency of read length and duplications, distribution of A/T/C/G/N and Q-scores in each base position.
Compared to Fast_QC_1.pl, this version can handle multiple fastq files simultaneously.

=head1 Usage

perl ./Fast_QC_2.perl -i 1.fastq 2.fastq ... [-o dir] [-h] [-v]

Makesure fastqc.perl and fastq files to check in the same director place, but this is not a must if you make fastqc.perl executable in the Bash $PATH, and 'perl' can be omitted in that case.

=head1 Author

SenWang
E-mail: wangsen1993@163.com

=head1 Update

Fast_QC_2.pl v2.0, 2018/11/28
Fast_QC_1.pl v 1.1, 2018/11/25
Fast_QC_1.pl v 1.0, 2018/11/23

=cut

use strict;
use Getopt::Long; #Pass parameters into program
use Cwd; #Capture the current working directory
use threads;
use threads::shared;

################### Options ####################
my (@input,$output,$version,$help,$t_start,$t_end,$t_consum);
my $options = GetOptions(
	'input|i=s{,}'=>\@input,
	'output|o:0'=>\$output,
	'version|v!'=>\$version,
	'help|h!'=>\$help,
);
die(`pod2text $0`) if (not defined(@input));
$output = cwd() if (not defined($output));
################# Main Routine #################
$t_start = localtime(time());
print "fastqc2.pl starts at: $t_start\n";
$t_start = time();
#create a child_process for each fastq file
foreach (@input) {
	threads->new(\&fastqc,$_,$output);
}
while (threads->list()) {
	$_->join() foreach threads->list(threads::joinable);
}
#indicate the end and the time taken
$t_end = localtime(time());
print "fastqc2.pl ends at: $t_end\n";
$t_end = time();
$t_consum = $t_end - $t_start;
print "the current process totally takes: $t_consum s\n";

############### Sub Routine #####################
sub fastqc {
	#open fastq file and create output file to process
	my $input = $_[0];
	my $dir = $_[1];
	open my $filein, "<$dir/$input" or die "Open fail: $!";
	open my $fileout, ">$dir/$input.qc2" or die "Create fail: $!";
	print "$input is under processing, output will be in $input.qc...\n";

	#read each line from the fastq file for parsing
	my ($N_reads,$Reads_with_N);
	my (@Nbases,@Qscores);
	my (%Count_seqs,%Len_seqs,%GC_seqs,%AvgQ_seqs);
	my $line = 0;
	while (<$filein>) {
		chomp;$line++;
		if (not($line % 2) and ($line % 4)) { #match a read line
			$N_reads++;$Count_seqs{$_}++; #count total reads and duplication time of each read
			my $l = length;$Len_seqs{"$l"}++; #count reads with the same length
			$Reads_with_N++ if (/N+/);
			my $i = 0;$l = 0;my $GC = 0;
			foreach my $b (split(//, $_)) { #convert read into array for parsing
				$i++;
				$Nbases[$i]{"$b"}++; #use hash to count A|T|C|G|N in each position
				$l++ if (not $b=~/N/);
				$GC++ if ($b =~ /[GC]/);
			}
			$GC = sprintf("%2d%%",$GC/$l*100);
			$GC_seqs{$GC}++;
		}
		elsif (not($line % 4)) {		
			my $j = 0;my $Qs = 0;
			foreach my $char (split(//,$_)) { #converst a Q-score line into an array for parsing			
				$j++; #base position
				my $q = ord($char) - 33; #Illumina 1.8+ Phred+33: 0 to 41
				$Qscores[$j]{"$q"}++; #use hash to count reads with the same Q-score in each position
				$Qs += $q
			}
			$Qs = sprintf("%2d",$Qs/$j);
			$AvgQ_seqs{$Qs}++;
		}
	}
	close $filein; 

	print "$N_reads reads in $input have been processed\n";
	print $fileout "Number of reads:\t$N_reads\n"; #ouput total read number
	print $fileout "Number of reads with unknown bases ('N'):\t$Reads_with_N"; #output number of reads with 'N' base

	#generate the distribution of read length
	print "start to count reads of the same length...\n";
	print $fileout "\nRead_length\tNumber_of_reads\tPercent_of_total\n";
	foreach (sort {$a <=> $b} keys %Len_seqs) {
		my $r = $Len_seqs{$_}/$N_reads*100;
		printf $fileout "%11d\t%15d\t%.4f%%\n", $_,$Len_seqs{$_},$r;
	}

	#generate the distribution of number of reads over GC%
	print "start to output the number of  reads with the same GC%\n";
	print $fileout "\nGC_percentage\tNumber_of_reads\n";
	foreach (sort {$a <=> $b} keys %GC_seqs) {
		printf $fileout "%13s\t%15d\n", $_,$GC_seqs{$_};
	}

	#generate the distribution of number of reads over Q_scores
	print "start to output the number of  reads with the same Q_score\n";
	print $fileout "\nQ_score\tNumber_of_reads\n";
	foreach (sort {$a <=> $b} keys %AvgQ_seqs) {
		printf $fileout "%7d\t%15d\n", $_,$AvgQ_seqs{$_};
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
	print $fileout "\nPos_B\tNumber_of_bases\tPercent_A\tPercent_T\tPercent_C\tPercent_G\tPercent_N\n";
	$pos = 0;
	foreach (@Nbases) {
		next if (not defined($_));
		$pos++;my %Freq_B;	
		foreach my $b (keys %$_) {
			$$_{$b} = 0 if (not defined($$_{$b}));
			$Freq_B{$b} = $$_{$b}/$N_B[$pos]*100;
		}	
		printf $fileout "%5d\t%15d\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\n",$pos,$N_B[$pos],$Freq_B{A},$Freq_B{T},$Freq_B{C},$Freq_B{G},$Freq_B{N};
	}

	#generate distribution of Q-scores in each position
	print "start to calculate the distribution of base Q-score in each position...\n";
	print $fileout "\nPos_B\tNumber_of_bases\tPer_Q=0\tPer_Q=1\tPer_Q=2\tPer_Q=3\tPer_Q=4\tPer_Q=5\tPer_Q=6\tPer_Q=7\tPer_Q=8\tPer_Q=9\tPer_Q10\tPer_Q11\tPer_Q12\tPer_Q13\tPer_Q14\tPer_Q15\tPer_Q16\tPer_Q17\tPer_Q18\tPer_Q19\tPer_Q20\tPer_Q21\tPer_Q22\tPer_Q23\tPer_Q24\tPer_Q25\tPer_Q26\tPer_Q27\tPer_Q28\tPer_Q29\tPer_Q30\tPer_Q31\tPer_Q32\tPer_Q33\tPer_Q34\tPer_Q35\tPer_Q36\tPer_Q37\tPer_Q38\tPer_Q39\tPer_Q40\tPer_Q41\n";
	$pos = 0;
	foreach (@Qscores) {
		next if (not defined($_));
		$pos++;my %Freq_Q;
		foreach my $q (keys %$_) {
			$$_{$q} = 0 if (not defined($$_{$q}));
			$Freq_Q{$q} = $$_{$q}/$N_B[$pos]*100;
		}
		printf $fileout "%5d\t%15d\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\t%.4f%%\n",$pos,$N_B[$pos],$Freq_Q{0},$Freq_Q{1},$Freq_Q{2},$Freq_Q{3},$Freq_Q{4},$Freq_Q{5},$Freq_Q{6},$Freq_Q{7},$Freq_Q{8},$Freq_Q{9},$Freq_Q{10},$Freq_Q{11},$Freq_Q{12},$Freq_Q{13},$Freq_Q{14},$Freq_Q{15},$Freq_Q{16},$Freq_Q{17},$Freq_Q{18},$Freq_Q{19},$Freq_Q{20},$Freq_Q{21},$Freq_Q{22},$Freq_Q{23},$Freq_Q{24},$Freq_Q{25},$Freq_Q{26},$Freq_Q{27},$Freq_Q{28},$Freq_Q{29},$Freq_Q{30},$Freq_Q{31},$Freq_Q{32},$Freq_Q{33},$Freq_Q{34},$Freq_Q{35},$Freq_Q{36},$Freq_Q{37},$Freq_Q{38},$Freq_Q{39},$Freq_Q{40},$Freq_Q{41};
	}

	#generate read duplication time
	print "start to count reads of the same occurance time...\n";
	print $fileout "\nDup_times\tNumber_of_reads\tPercent_of_total\n";
	my %Freq_seqs;
	foreach (values %Count_seqs) {
		$Freq_seqs{$_}++;
	}
	foreach (sort {$a <=> $b} keys %Freq_seqs) {
		my $r = $Freq_seqs{$_}/$N_reads*100;
		printf $fileout "%9d\t%15d\t%.4f%%\n",$_,$Freq_seqs{$_},$r;
	}
	close $fileout;
}
