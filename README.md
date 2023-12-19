These scripts were written by me, Mackenzie Noon (mackenzie.noon@yale.edu). Contact me with any questions.

In this directory, a yml file is provided which should allow you to make a conda environment that will facilitate recapitulation of all my results.

You will probably have to change the "prefix" filepath to match your system, but the software and associated versions are all there. 

Worflow also includes some shell code, and so uses awk, wc, other similar utilities. 

The goal of this analysis is to .... [WRITE ME]

The basic flow:

[input data] -> 0. merge -> 1. annotate -> 2. count -> 3. graph

Additionally "intuition" ...


...

AF, AC & AN

(from tooltips on gnomad website)

AC : Allele Count : "Alternate allele count in high-quality genotypes"
AN : Allele Number : "Total high quality genotypes"
AF : Allele Frequency : "Alternate Allele Frequency in high quality genotypes"

AF=AC/AN

I define : MAF (minor allele frequency) = min(AF,1-AF)

gnomad filters 1) filter = pass, 2) maf != 0, 3) AN >= 76,156
- 76,156 is [the number of high-quality genomes in 3.1](https://gnomad.broadinstitute.org/news/2020-10-gnomad-v3-1/)
- Therefore, if a site were called in all individuals it would be 76,156\*2 . Gnomad sometimes issues the following warning

> Warning This variant is covered in fewer than 50% of individuals in gnomAD v3.1.2 genomes. This may indicate a low-quality site.

Example : [rs113653250](https://gnomad.broadinstitute.org/variant/1-434284-T-G?dataset=gnomad_r3)

...


- 

We're using gnomad v3.1.2. 

activity ref OR alt:
(-Inf,1), [1,2), [2,4), [4,6), [6,Inf) (note first bin we would call as not active)
- I am worried that this will lose directional effects. I will make separate sets of bins for REF and ALT. 

allelic skew:
(-Inf, -1.5), [-1.5, 1), [-1, -0.5), [-0.5, 0), [0, 0.5), [0.5, 1), [1, 1.5), [1.5, Inf) (note middle two bins we would not call as emvars)

...

Todo
- [x] Fix genotype number cutoff
- [x] annotated directly from GRCh38-cCREs.V4.bed.gz, make all types
    - [x] Get list of unique 
- [x] chr22 : Re-run annotate on chr 22 with fixed filtering parameters
    - [x] check if slurm can still write to output files in branches (it can't, let's just not track them)
- [~] crunch my way through the rest of the chromosomes
- [ ] manually check annotations in IGV. 
- [ ] regraph chr22
    - [ ] modify graphing programs to be name agnostic.
    - [ ] modify to put . instead of - in the graphs
    - [ ] fix thresholds
        - [ ] new thresholds (subdivide beyond figs), & break alt & ref into separate columns
03:43:07 = chr22 ~1.6% of the genome (job id = 15959386). Maximum allocation time for ycga is 2 days = 48 hrs. 

1.7%/03:43:07 = x/48

1.7%/3.72 = x/48

x~=20

Round down to 15% for safety. 



https://hgdownload.cse.ucsc.edu/goldenpath/hg38/bigZips/



['dELS', 'CA', 'pELS', 'CA-H3K4me3', 'CA-CTCF', 'PLS', 'TF', 'CA-TF']

0. merge 
Adds malinouis predictions to datasets

1. annotate


(interpretations)
CADD

>To simplify interpretation in some contexts, we also defined phred-like scores (scaled C  scores) on the basis of the rank of the C score of each variant relative  to all 8.6 billion possible SNVs, ranging from 1 to 99 (Supplementary  Note). For example, substitutions with the highest 10% (10−1) of all  scores—that is, those least likely to be observed human alleles under  our model—were assigned values of 10 or greater (‘≥C10’), whereas  variants  in  the  highest  1%  (10^−2),  0.1%  (10^−3),  etc.  were  assigned  scores ‘≥C20’, ‘≥C30’, etc

(A general framework for estimating the relative pathogenicity of human genetic variants, nature genetics, 2014)

PhyloP
- 

ensembl VEP
- 
