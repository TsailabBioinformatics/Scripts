#!/bin/bash

platform="Zcluster"
mode="paired-end"

####################### this starts with proteome #######################
## this part only needs to be run once, it prepares and formats the data
## manually run
# WU-BLAST, construct similarity matrix for ortholog group clustering
#/usr/local/wublast/latest/xdformat -p -o 01.data/03.MCL/01.blast/database 01.data/00.PriorData/proteome.fa
#/usr/local/wublast/latest/blastp 01.data/03.MCL/01.blast/database 01.data/00.PriorData/proteome.fa -o 01.data/03.MCL/01.blast/wu.blast.all.out -e 1e-5 -mformat 2 -cpus 4 -wordmask seg

## manually run
# mcl, cluster ortholog groups
#time perl 00.script/a1.mcl.prepare.graph.pl 01.data/03.MCL/01.blast/wu.blast.all.out 01.data/03.MCL/02.mcl/mcl.graph.txt wu
#time /usr/local/mcl/latest/bin/mcl 01.data/03.MCL/02.mcl/wu.mcl.graph.txt --abc -o 01.data/03.MCL/02.mcl/mcl.out.txt -I 1.5

## manually run
# construct meta-group, combine ortholog groups into meta-group, each group contains 1000 genes
#module load R/3.1.2    # this is for Sapelo
#time /usr/local/apps/R/3.1.2/bin/Rscript 00.script/a3.geneSelection.R 01.data/03.MCL/02.mcl/mcl.out.txt 01.data/04.GeneOfInterest/GeneID.txt 1000 Potri

## manually run
# split gene, based on the meta-group, split gene sequences accordingly
#time perl 00.script/a4.splitGene.pl 01.data/00.PriorData/proteome.fa 01.data/04.GeneOfInterest/GeneID.txt 01.data/05.splitGenes/01.Protein/run.0 1000
#time perl 00.script/a4.splitGene.pl 01.data/00.PriorData/transcriptome.fa 01.data/04.GeneOfInterest/GeneID.txt 01.data/05.splitGenes/02.Transcript/run.0 1000

## manually run
# get meta-data for the meta-group, eg. gene/protein length, which group each gene belongs to
#time perl 00.script/a5.releventInfo.pl 01.data/04.GeneOfInterest/GeneID.txt 01.data/00.PriorData/proteome.fa 01.data/00.PriorData/transcriptome.fa 01.data/00.PriorData/gene.gff3 01.data/04.GeneOfInterest/GeneID.v1.txt 1000
