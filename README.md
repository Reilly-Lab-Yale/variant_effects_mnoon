These scripts were written by me, Mackenzie Noon (mackenzie.noon@yale.edu). Contact me with any questions.

In this directory, a yml file is provided which should allow you to make a conda environment that will facilitate recapitulation of all my results.

You will probably have to change the "prefix" filepath to match your system, but the software and associated versions are all there. 

Worflow also includes some shell code, and so uses awk, wc, other similar utilities. 

The goal of this analysis is to .... [WRITE ME]

The basic flow:

[input data] -> 0. merge -> 1. annotate -> 2. filter -> 3. graph

0. merge 
Adds malinouis predictions to datasets

1. annotate
Adds PhyloP scores

2. filter
Produces summaries of bins of variant categories 

(interpretations)
CADD

>To simplify interpretation in some contexts, we also defined phred-like scores (scaled C  scores) on the basis of the rank of the C score of each variant relative  to all 8.6 billion possible SNVs, ranging from 1 to 99 (Supplementary  Note). For example, substitutions with the highest 10% (10−1) of all  scores—that is, those least likely to be observed human alleles under  our model—were assigned values of 10 or greater (‘≥C10’), whereas  variants  in  the  highest  1%  (10^−2),  0.1%  (10^−3),  etc.  were  assigned  scores ‘≥C20’, ‘≥C30’, etc

(A general framework for estimating the relative pathogenicity of human genetic variants, nature genetics, 2014)

PhyloP
- 

ensembl VEP
- 
