# hello-world

Fast_QC_2.pl

This program read original fastq files from Illumina platforms and produce the quality reports in a new user-defined file.
It includes number of total reads, frequency of read length and duplications, distribution of A/T/C/G/N and Q-scores in each base position.

Compared to Fast_QC_1.pl, this version can handle multiple fastq files simultaneously.

perl ./Fast_QC_2.perl -i 1.fastq 2.fastq ... [-o dir] [-h] [-v]

Makesure fastqc.perl and fastq files to check in the same director place, but this is not a must if you make fastqc.perl executable in the Bash $PATH, and 'perl' can be omitted in that case.

If you find any bug, please contact me:
SenWang
E-mail: wangsen1993@163.com

Updates:
Fast_QC_2.pl v2.0, 2018/11/28
Fast_QC_1.pl v 1.1, 2018/11/25
Fast_QC_1.pl v 1.0, 2018/11/23

