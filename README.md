## perl scripts to process fastq or fasta files

`perl Fastq_QC_v1.pl -i *.fastq[.gz] -o *.qc [-h] [-v]`

This program read original fastq files from Illumina platforms and produce the quality reports in a new user-defined file. It includes number of total reads, frequency of read length and duplications, distribution of A/T/C/G/N and Q-scores in each base position.

`perl Fastq_QC_v2.pl -i 1.fq 2.fastq 3.fastq.gz 4.fq.gz ... [-o dir] [-h] [-v]`

This program read original fastq files from Illumina platforms and produce the quality reports in a new user-defined file. It includes number of total reads, frequency of read length and duplications, distribution of A/T/C/G/N and Q-scores in each base position. Compared to fastqc.pl, this version can handle multiple fastq files simultaneously, and gzip compressed files are also supported.

` `



The above commands should be run with the fastq or fastq.gz files in the same directory, unless you make them executable in $PATH.

Please contact me if you encounter any bug when using thess scripts:  
Sen Wang, wangsen1993@163.com.
