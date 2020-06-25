## perl scripts to process fastq or fasta files

`perl Fastq_QC_v1.pl -i *.fastq[.gz] -o *.qc [-h] [-v]`

This script read original fastq files from Illumina platforms and produce the quality reports in a new user-defined file. It includes number of total reads, frequency of read length and duplications, distribution of A/T/C/G/N and Q-scores in each base position.

`perl Fastq_QC_v2.pl -i 1.fq 2.fastq 3.fastq.gz 4.fq.gz ... [-o dir] [-h] [-v]`

This script read original fastq files from Illumina platforms and produce the quality reports in a new user-defined file. It includes number of total reads, frequency of read length and duplications, distribution of A/T/C/G/N and Q-scores in each base position. Compared to `Fastq_QC_v1.pl`, this version can handle multiple fastq files simultaneously, and gzip compressed files are also supported.

`perl fasta_oneline.pl input.fasta > output.fasta`

This script read a fasta file in the format of multi-lines (e.g. 60 letters perl line) per sequence and output in the format of one-line per sequence.

`perl rep_select.pl rep_seq.fasta raw_seq.fasta > raw_rep_seq.fasta`

This script read two fasta files with headers in the same format, search in the second file for the sequences with their headers appeared in the first file, and output the found headers and their sequences.

`perl format_fasta.pl input.fasta > output.fasta`

This script read a fasta file with long and complex headers, cut off the unnecessary header strings at the first blank from left to right, and output the shortened headers and sequences in the original order.

The above commands should be run with the fastq or fastq.gz files in the same directory, unless you make them executable in $PATH.

Please contact me if you encounter any bug when using thess scripts:  
Sen Wang, wangsen1993@163.com.
