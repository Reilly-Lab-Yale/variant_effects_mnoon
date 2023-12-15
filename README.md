These scripts were written by me, Mackenzie Noon (mackenzie.noon@yale.edu). Contact me with any questions.

In this directory, a yml file is provided which should allow you to make a conda environment that will facilitate recapitulation of all my results.

You will probably have to change the "prefix" filepath to match your system, but the software and associated versions are all there. 

Worflow also includes some shell code, and so uses awk, wc, other similar utilities. 

The goal of this analysis is to .... [WRITE ME]

The basic flow:

[input data] -> 0. merge -> 1. annotate -> 2. count -> 3. graph


...

AF, AC & AN

(from tooltips on gnomad website)

AC : Allele Count : "Alternate allele count in high-quality genotypes"
AN : Allele Number : "Total high quality genotypes"
AF : Allele Frequency : "Alternate Allele Frequency in high quality genotypes"

AF=AC/AN

I define : MAF (minor allele frequency) = min(AF,1-AF)

...

gnomad filters 1) filter = pass, 2) maf != 0, 3) allele number >= 76,156

activity ref OR alt:
(-Inf,1), [1,2), [2,4), [4,6), [6,Inf) (note first bin we would call as not active)
- I am worried that this will lose directional effects. 

allelic skew:
(-Inf, -1.5), [-1.5, 1), [-1, -0.5), [-0.5, 0), [0, 0.5), [0.5, 1), [1, 1.5), [1.5, Inf) (note middle two bins we would not call as emvars)

...

Todo
- [ ] Check allele number cutoff
- [ ] Re-run annotate on chr 22 with fixed filtering parameters
- [ ] Branch : modify annotate to work with caching & more CPUs


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
