## perl scripts to process fastq or fasta files

This is my first script written in perl, which can be used to check the qualities of raw reads (fastq files) from Illumina sequencing platforms (1.8+).
`Fastq_QC_v2.pl`
This program read original fastq files from Illumina sequencing platforms and produce the quality statistics in a new file. The output includes number of total reads, frequency of read length and duplications, distribution of A/T/C/G/N and Q-scores in each base position.

Compared to `Fast_QC_v1.pl`, this version can handle multiple fastq (also gzip compressed fastq.gz) files simultaneously.

`perl ./Fastq_QC_v2.pl -i read1.fq read2.fq.gz ... -o read.report [-h] [-v]`

The above command can only be run when `Fastq_QC_v2.pl` and the fastq or fastq.gz files to process are in the same directory. You can also run it directly if `Fastq_QC_v2.pl` is executable in $PATH, and perl ./ can be omitted in that case.

If you encounter any bug when using this script, please contact me:  
Sen Wang, wangsen1993@163.com.
