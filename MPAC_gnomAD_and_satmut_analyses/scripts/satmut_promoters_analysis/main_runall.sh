#!/bin/sh

# Motif analyses
Rscript -e "rmarkdown::render('satmut_promoters_meme.Rmd')"

# Meta-promoter analyses
Rscript -e "rmarkdown::render('satmut_promoters_overall_dist.Rmd')"

# Big heatmap analyses
Rscript -e "rmarkdown::render('satmut_promoters_overall_bigheat.Rmd')"

# Overall correlation analyses
Rscript -e "rmarkdown::render('satmut_promoters_overall_corr.Rmd')"

# Stratified promoter analyses
Rscript -e "rmarkdown::render('satmut_promoters_strat_promoters.Rmd')"

# Individual promoter analyses
Rscript -e "rmarkdown::render('satmut_promoters_indiv_promoters.Rmd')"

# Oveview of individual promoters analyses
Rscript -e "rmarkdown::render('satmut_promoters_overall_promoter.Rmd')"
