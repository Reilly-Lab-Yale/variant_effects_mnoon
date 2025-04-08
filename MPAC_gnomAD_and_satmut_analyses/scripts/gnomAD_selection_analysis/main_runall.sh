#!/bin/sh

# MPAC gnomAD analyses of purifying selection
Rscript -e "rmarkdown::render('gnomAD_purifying_selection_v2.Rmd')"

# Ensembl VEP analyses of purifying selection
Rscript -e "rmarkdown::render('gnomAD_ensembl_vep_v2.Rmd')"

# Miscellaneous analyses of mean predictions
Rscript gnomAD_miscellaneous_calculations_avgs.R

# Miscellaneous analyses of TF enrichment
Rscript gnomAD_miscellaneous_calculations_TFs.R
