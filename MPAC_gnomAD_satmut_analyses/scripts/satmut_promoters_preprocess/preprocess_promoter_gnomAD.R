#!/bin/R

# Annotate with observed variants in gnomAD and their allele frequencies

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

	# load gnomAD
	satmut_promoters_pred <- as_tibble(fread(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_pred/satmut_promoters_pred_", chr, ".txt.gz"))) %>% 
		dplyr::select(chrom, pos, ref, alt, id, strand, tss_dist)  # , ref_orig, alt_orig)
	gnomAD_variants_only <- as_tibble(fread(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_gnomAD/gnomad.genomes.v3.1.2.sites.", chr, ".subinfo.promoter.vcf.gz"), sep="\t")) %>% 
		distinct()  # necessary because of overlapping promoters
	names(gnomAD_variants_only) <- c("chrom", "pos", "id", "ref", "alt", "qual", "filter", "info")
	
	# split info
	gnomAD_variants_only_info <- gnomAD_variants_only %>% 
		mutate(info = stri_split_fixed(info, ";")) %>% 
		filter(filter == "PASS") %>% 
		unnest(info)
	
	gnomAD_variants_only_info <- gnomAD_variants_only_info %>% 
		mutate(info_value = gsub(".*=", "", info)) %>% 
		mutate(info_name = gsub("=.*", "", info)) %>% 
		dplyr::select(-info) %>% 
		pivot_wider(names_from=info_name, values_from=info_value)

	# apply qc filters
	gnomAD_variants_pass_only <- gnomAD_variants_only_info %>% 
		mutate(
			AC = as.numeric(AC), 
			AN = as.numeric(AN), 
			AF = as.numeric(AF)
		) %>% 
		filter(pmin(AF, 1-AF)>0) %>% 
		filter(AN >= 76156) %>% 
		mutate(gnomAD_in_WGS = TRUE)

	# get variant af bins
	gnomAD_variants_pass_only <- gnomAD_variants_pass_only %>% 
		mutate(gnomAD_in_WGS_category = 
			ifelse(pmin(AF, 1-AF)>0.001, "common", "rare")) %>% 
		mutate(gnomAD_in_WGS_category_alt = 
			ifelse(pmin(AF, 1-AF)>=0.01, "common", 
			ifelse(pmin(AF, 1-AF)>=0.001, "low-freq", 
			ifelse(pmin(AF, 1-AF)>=0.0001, "rare", 
			ifelse(pmin(AF, 1-AF)>=0.00001, "ultra-rare", 
			ifelse((AC==1) | (AC==(AN-1)), "singleton", NA
		)))))) %>% 
		dplyr::rename(
			gnomAD_AC = AC, 
			gnomAD_AN = AN, 
			gnomAD_AF = AF
		) %>% 
		dplyr::select(chrom, pos, ref, alt, gnomAD_AC, gnomAD_AN, gnomAD_AF, 
			gnomAD_in_WGS, gnomAD_in_WGS_category, gnomAD_in_WGS_category_alt)

	# join gnomAD
	satmut_promoters_pred_gnomAD <- satmut_promoters_pred %>% 
		inner_join(gnomAD_variants_pass_only) %>% 
		mutate(gnomAD_in_WGS = ifelse(is.na(gnomAD_in_WGS), FALSE, gnomAD_in_WGS)) %>% 
		mutate(gnomAD_in_WGS_category = ifelse(is.na(gnomAD_in_WGS_category), "unobserved", gnomAD_in_WGS_category)) %>% 
		mutate(gnomAD_in_WGS_category_alt = ifelse(is.na(gnomAD_in_WGS_category_alt), "unobserved", gnomAD_in_WGS_category_alt))

	# check counts
	print(table(satmut_promoters_pred_gnomAD$gnomAD_in_WGS_category))
	print(table(satmut_promoters_pred_gnomAD$gnomAD_in_WGS_category_alt))

	# save predictions and gnomAD
	write_tsv(satmut_promoters_pred_gnomAD, gzfile(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_pred_gnomAD/satmut_promoters_pred_gnomAD_", chr, ".txt.gz")))
}
