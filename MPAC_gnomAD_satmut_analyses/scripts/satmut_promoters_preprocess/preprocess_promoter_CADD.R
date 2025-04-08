#!/bin/R

# Annotate with CADD scores and Zoonomia phyloP scores (sanity check) and Roulette mutation rate estimates

# load libraries
library(data.table)
library(tidyverse)
library(stringi)

# load bioconductor
library(plyranges)
library(rtracklayer)

# loop chromosomes
for (chr in paste0("chr", c(22:1))) {
	print(chr)

	# load CADD
	satmut_promoters_pred <- as_tibble(fread(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_pred/satmut_promoters_pred_", chr, ".txt.gz"))) %>% 
		dplyr::select(chrom, pos, ref, alt, id, strand, tss_dist)  # , ref_orig, alt_orig)
	CADD_variants_only <- as_tibble(fread(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_CADD/whole_genome_SNVs_inclAnno.", gsub("chr", "", chr), ".subinfo.promoter.txt.gz"), sep=" ")) %>% 
		mutate(`#Chrom` = paste0("chr", `#Chrom`)) %>%  # convert chromosomes
		dplyr::select(`#Chrom`, Pos, Ref, Alt, `Roulette-MR`, `PHRED`) %>%  # get only Roulette scores
		group_by(`#Chrom`, Pos, Ref, Alt) %>% 
		filter(`PHRED` == max(`PHRED`)) %>%  # get row (transcript) with highest CADD score
		ungroup() %>% 
		distinct()  # necessary because multiple transcripts in CADD but these do not affect Roulette

	names(CADD_variants_only) <- c("chrom", "pos", "ref", "alt", "CADD_Roulette_MR", "CADD_PHRED")

	# join CADD
	satmut_promoters_pred_CADD <- satmut_promoters_pred %>% 
		inner_join(CADD_variants_only)

	# check
	nrow(satmut_promoters_pred) == nrow(satmut_promoters_pred_CADD)
	table(!is.na(satmut_promoters_pred_CADD$CADD_Roulette_MR))

	# save predictions and CADD
	write_tsv(satmut_promoters_pred_CADD, gzfile(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_pred_CADD/satmut_promoters_pred_CADD_", chr, ".txt.gz")))
}
