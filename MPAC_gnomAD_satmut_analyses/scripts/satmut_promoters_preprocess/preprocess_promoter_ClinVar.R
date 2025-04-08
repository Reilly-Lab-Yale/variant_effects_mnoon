#!/bin/R

# Annotate with observed variants in ClinVar and their pathogenicity

# load libraries
library(tidyverse)
library(data.table)
library(stringi)
library(vcfR)

# load vcf
clinvar_variants <- as_tibble(read.vcfR("../../data/disease_annotations/clinvar_20240421.vcf.gz")@fix) %>% 
	mutate(INFO = stri_split_fixed(INFO, ";")) %>% 
	unnest(INFO) %>% 
	mutate(INFO_value = gsub(".*=", "", INFO)) %>% 
	mutate(INFO_name = gsub("=.*", "", INFO)) %>% 
	dplyr::select(-INFO) %>% 
	pivot_wider(names_from=INFO_name, values_from=INFO_value)

# filter vcf
# 	see https://www.ncbi.nlm.nih.gov/clinvar/docs/review_status/
clinvar_variants_filter <- clinvar_variants %>% 
	filter(CLNVC %in% c("single_nucleotide_variant")) %>% 
	# 1 star and above variants w/o conflict
	filter(CLNREVSTAT %in% c("practice_guideline", "reviewed_by_expert_panel", "criteria_provided,_multiple_submitters,_no_conflicts", "criteria_provided,_single_submitter"))

clinvar_variants_filter_pathogenic <- filter(clinvar_variants_filter, grepl("Pathogenic|pathogenic", CLNSIG)) %>% 
	dplyr::select(CHROM, POS, REF, ALT, MC) %>% 
	mutate(ClinVar = "(Likely)_pathogenic") %>% 
	mutate(CHROM = paste0("chr", CHROM)) %>% 
	mutate(POS = as.integer(POS))
names(clinvar_variants_filter_pathogenic) <- c("chrom", "pos", "ref", "alt", "ClinVar_MC", "ClinVar_category")

clinvar_variants_filter_benign <- filter(clinvar_variants_filter, grepl("Benign|benign", CLNSIG)) %>% 
	dplyr::select(CHROM, POS, REF, ALT, MC) %>% 
	mutate(ClinVar = "(Likely)_benign") %>% 
	mutate(CHROM = paste0("chr", CHROM)) %>% 
	mutate(POS = as.integer(POS))
names(clinvar_variants_filter_benign) <- c("chrom", "pos", "ref", "alt", "ClinVar_MC", "ClinVar_category")

clinvar_variants_filter_merged <- bind_rows(clinvar_variants_filter_pathogenic, clinvar_variants_filter_benign)

# save vcf
write_tsv(clinvar_variants_filter_pathogenic, gzfile("../../results/satmut_promoters_preprocess/satmut_promoters_pred_ClinVar/clinvar_variants_filter_pathogenic.txt.gz"))
write_tsv(clinvar_variants_filter_benign, gzfile("../../results/satmut_promoters_preprocess/satmut_promoters_pred_ClinVar/clinvar_variants_filter_benign.txt.gz"))
write_tsv(clinvar_variants_filter_merged, gzfile("../../results/satmut_promoters_preprocess/satmut_promoters_pred_ClinVar/clinvar_variants_filter_merged.txt.gz"))

# loop chromosomes
for (chr in paste0("chr", c(22:1))) {
	print(chr)

	# load ClinVar
	satmut_promoters_pred <- as_tibble(fread(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_pred/satmut_promoters_pred_", chr, ".txt.gz"))) %>% 
		dplyr::select(chrom, pos, ref, alt, id, strand, tss_dist)  # , ref_orig, alt_orig)

	# join ClinVar
	satmut_promoters_pred_ClinVar <- satmut_promoters_pred %>% 
		inner_join(clinvar_variants_filter_merged)

	# save predictions and ClinVar
	write_tsv(satmut_promoters_pred_ClinVar, gzfile(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_pred_ClinVar/satmut_promoters_pred_ClinVar_", chr, ".txt.gz")))
}
