Hello, Git!

I am a new hand in coding and at the begining of working on bioinformatics. Thanks to Git, I can access so much information and material and stay in touch with so many resources and masters. I will try my best to learn and work!

The following is my first script written in Perl, which can be used to check the qualities of raw reads (fastq files) from Illumina sequencing platforms (1.8+).

I'll be very happy if this program can give you any help.
Thanks for your interest and comments and suggestions are really appreciated!

Fastq_QC_v2.pl

This program read original fastq files from Illumina platforms and produce the quality reports in a new user-defined file.
It includes number of total reads, frequency of read length and duplications, distribution of A/T/C/G/N and Q-scores in each base position.

Compared to Fast_QC_1.pl, this version can handle multiple fastq files simultaneously.

perl ./Fastq_QC_v2.pl -i 1.fastq 2.fastq ... [-o dir] [-h] [-v]

Makesure fastqc.perl and fastq files to check in the same director place, but this is not a must if you make fastqc.perl executable in the Bash $PATH, and 'perl' can be omitted in that case.

If you encounter any bug when using this program, please contact me:
Sen Wang, wangsen1993@163.com.

Updates:
Fastq_QC_v2.pl v2.1, 2018/12/11;
Fastq_QC_v2.pl v2.0, 2018/11/28;
Fastq_QC_v1.pl v 1.1, 2018/11/25;
Fastq_QC_v1.pl v 1.0, 2018/11/23.
