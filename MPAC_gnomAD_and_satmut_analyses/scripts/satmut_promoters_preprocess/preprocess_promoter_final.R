#!/bin/R

# Collate annotations for all tables for all chromosomes

# load libraries
library(tidyverse)
library(data.table)

# loop chromosomes
for (chr in paste0("chr", c(22:1))) {
	print(chr)

	# load ClinVar
	satmut_promoters_final <- as_tibble(fread(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_pred/satmut_promoters_pred_", chr, ".txt.gz")))
	satmut_promoters_final <- satmut_promoters_final %>% 
		left_join(as_tibble(fread(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_pred_phyloP/satmut_promoters_pred_phyloP_", chr, ".txt.gz"))))
	satmut_promoters_final <- satmut_promoters_final %>% 
		left_join(as_tibble(fread(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_pred_CADD/satmut_promoters_pred_CADD_", chr, ".txt.gz"))))
	satmut_promoters_final <- satmut_promoters_final %>% 
		left_join(as_tibble(fread(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_pred_gnomAD/satmut_promoters_pred_gnomAD_", chr, ".txt.gz"))))
	satmut_promoters_final <- satmut_promoters_final %>% 
		left_join(as_tibble(fread(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_pred_ClinVar/satmut_promoters_pred_ClinVar_", chr, ".txt.gz"))))
	save predictions and ClinVar
	write_tsv(satmut_promoters_final, gzfile(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_final/satmut_promoters_final_", chr, ".txt.gz")))
}
