#!/bin/bash
#Author: Shea Lambert

#This script is for creating an alignment with one randomly sampled haplotype for each locus and individual, using a phased alignment containing two haplotypes per individual
#First, split a phylip file containing 2 haplotypes for each individual into separate files for each locus. I use RAXML v8.X and the "-f s" option for this.
#Then, for each phylip file (containing haplotypes for 1 locus), we will sample a random haplotype for each individual. 
#Individual names must be defined in the names.txt file
#List of phylip files should be in loci.list
parallel 'grep {1} loci/{2} | shuf | head -n 1 >> 1/{2}.resampled' :::: ./names.txt loci.list

##Now to combine loci into a concatenated, resampled alignment
##remove names from resampled haplotypes
ls *resampled | parallel "cat {} | sed 's/ /\t/g' | cut -f2 > {.}.raw"
##paste resampled haplotypes together
paste *.raw -d '' > all.concat.raw
##put names back 
paste ../names.txt all.concat.raw -d' ' > all.concat.named
##get the new number of taxa and seqlen
ntax=`wc -l all.concat.raw`
let count=`awk 'NR==5' all.concat.named | awk '{print $2}' | wc -m`-1
##replace header
cat <(echo $ntax	$count) all.concat.named > all.concat.named.phy

##The above will create a single resampled replicate. 
