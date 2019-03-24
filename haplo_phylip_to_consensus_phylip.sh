#!/bin/bash
#Author: Shea Lambert

#this script will convert a phylip file ("myfile.phy") containing two haplotype sequences per individual into a phylip file ("myfile.consensus.phy") containing the consensus sequence (using IUPAC ambiguities) for each individual. 


#convert phylip to fasta
perl phylip2fasta.pl myfile.phy  myfile.fasta

#split fasta up into haplotypes paired by individual
split -l 4  myfile.fasta

#call consensus sequences
#for i in x*; do perl consensus.pl -in $i -out consensus.$i -iupac; done
parallel perl consensus.pl -in {} -out consensus.{.} -iupac ::: x*

#extract consensus for each individual
for i in x*; do head -n 1 $i > $i.name.con; tail -n +2 consensus.$i | tr -d '\n' >> $i.name.con; done

#combine all consensus into one fasta
sed -e '$s/$/\n/' -s *.con > myfile.consensus.fasta

#convert fasta to phylip
perl fasta2phylip_SML.pl myfile.consensus.fasta > myfile.consensus.phy

##clean up
mkdir consensus
mv consensus.x* consensus/
mv x* consensus/
##the consensus/ directory contains intermediate files only and can be removed
