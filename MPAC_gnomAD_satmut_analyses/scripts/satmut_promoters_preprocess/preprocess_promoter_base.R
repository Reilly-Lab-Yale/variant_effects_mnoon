#!/bin/R

# Get base level and promoter level predictions

library(tidyverse)
library(data.table)

# set.seed(123456789)

# base-level summaries
for (chr in paste0("chr", c(22:1))) {
	print(chr)
	
	# load variant data
	satmut_promoters_final <- as_tibble(fread(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_final/satmut_promoters_final_", chr, ".txt.gz")))

	# summ base-level data
	satmut_promoters_final_base <- satmut_promoters_final %>% 
		group_by(
			chrom, pos, id, strand, tss_dist, 
			in_promoter_1kb, in_promoter_750bp, in_promoter_500bp, in_promoter_250bp, 
			in_promoter_quartile, in_all_exon, in_all_exon_splice  # , in_TFfoot
		) %>% 
		summarise(
			# basic summaries
			K562_ref_pred_base = mean(K562_ref_pred, na.rm=T), 
			HepG2_ref_pred_base = mean(HepG2_ref_pred, na.rm=T), 
			SKNSH_ref_pred_base = mean(SKNSH_ref_pred, na.rm=T), 
			avgKHS_ref_pred_base = mean(avgKHS_ref_pred, na.rm=T), 

			K562_alt_pred_base = mean(K562_alt_pred, na.rm=T), 
			HepG2_alt_pred_base = mean(HepG2_alt_pred, na.rm=T), 
			SKNSH_alt_pred_base = mean(SKNSH_alt_pred, na.rm=T), 
			avgKHS_alt_pred_base = mean(avgKHS_alt_pred, na.rm=T), 
		
			K562_skew_pred_base = mean(K562_skew_pred, na.rm=T), 
			HepG2_skew_pred_base = mean(HepG2_skew_pred, na.rm=T), 
			SKNSH_skew_pred_base = mean(SKNSH_skew_pred, na.rm=T), 
			avgKHS_skew_pred_base = mean(avgKHS_skew_pred, na.rm=T), 

			K562_activity_pred_base = mean(K562_activity_pred, na.rm=T), 
			HepG2_activity_pred_base = mean(HepG2_activity_pred, na.rm=T), 
			SKNSH_activity_pred_base = mean(SKNSH_activity_pred, na.rm=T), 
			avgKHS_activity_pred_base = mean(avgKHS_activity_pred, na.rm=T), 
		
			K562_abs_skew_pred_base = mean(K562_abs_skew_pred, na.rm=T), 
			HepG2_abs_skew_pred_base = mean(HepG2_abs_skew_pred, na.rm=T), 
			SKNSH_abs_skew_pred_base = mean(SKNSH_abs_skew_pred, na.rm=T), 
			avgKHS_abs_skew_pred_base = mean(avgKHS_abs_skew_pred, na.rm=T), 

			# how many active are at this base
			K562_active_base = sum(K562_active, na.rm=T), 
			HepG2_active_base = sum(HepG2_active, na.rm=T), 
			SKNSH_active_base = sum(SKNSH_active, na.rm=T), 
			avgKHS_active_base = sum(avgKHS_active, na.rm=T), 
			anyKHS_active_base = sum(anyKHS_active, na.rm=T), 

			# how many emVars are at this base
			K562_emVar_base = sum(K562_emVar, na.rm=T), 
			HepG2_emVar_base = sum(HepG2_emVar, na.rm=T), 
			SKNSH_emVar_base = sum(SKNSH_emVar, na.rm=T), 
			avgKHS_emVar_base = sum(avgKHS_emVar, na.rm=T), 
			anyKHS_emVar_base = sum(anyKHS_emVar, na.rm=T), 

			# how many pos emVars are at this base
			K562_emVar_pos_base = sum(K562_emVar_pos, na.rm=T), 
			HepG2_emVar_pos_base = sum(HepG2_emVar_pos, na.rm=T), 
			SKNSH_emVar_pos_base = sum(SKNSH_emVar_pos, na.rm=T), 
			avgKHS_emVar_pos_base = sum(avgKHS_emVar_pos, na.rm=T), 
			anyKHS_emVar_pos_base = sum(anyKHS_emVar_pos, na.rm=T), 

			# how many neg emVars are at this base
			K562_emVar_neg_base = sum(K562_emVar_neg, na.rm=T), 
			HepG2_emVar_neg_base = sum(HepG2_emVar_neg, na.rm=T), 
			SKNSH_emVar_neg_base = sum(SKNSH_emVar_neg, na.rm=T), 
			avgKHS_emVar_neg_base = sum(avgKHS_emVar_neg, na.rm=T), 
			anyKHS_emVar_neg_base = sum(anyKHS_emVar_neg, na.rm=T), 

			# how much conservation
			phyloP_mam241_base = mean(phyloP_mam241, na.rm=T), 
			phyloP_mam241_pos_base = mean(phyloP_mam241_pos, na.rm=T), 
			phyloP_mam241_neg_base = mean(phyloP_mam241_neg, na.rm=T), 
			phyloP_mam241_cons_base = mean(phyloP_mam241_cons, na.rm=T), 

			# how much cadd score
			CADD_Roulette_MR_base = mean(CADD_Roulette_MR, na.rm=T),
			CADD_PHRED_base = mean(CADD_PHRED, na.rm=T),

			# is there a WGS variant at this base
			gnomAD_in_WGS_base = sum(gnomAD_in_WGS, na.rm=T) > 0, 
			gnomAD_in_WGS_rare_base = sum(gnomAD_in_WGS_category == "rare", na.rm=T) > 0, 
			gnomAD_in_WGS_common_base = sum(gnomAD_in_WGS_category == "common", na.rm=T) > 0, 

			# is there a ClinVar variant at this base
			ClinVar_is_likely_benign_base = sum(ClinVar_category == "(Likely)_benign", na.rm=T) > 0, 
			ClinVar_is_likely_pathogenic_base = sum(ClinVar_category == "(Likely)_pathogenic", na.rm=T) > 0, 
		) %>% 
		# additional features used for signed correlations
		mutate(
			sign_K562_skew_pred_base = ifelse(K562_skew_pred_base > 0, "pos", "neg"),
			sign_HepG2_skew_pred_base = ifelse(HepG2_skew_pred_base > 0, "pos", "neg"),
			sign_SKNSH_skew_pred_base = ifelse(SKNSH_skew_pred_base > 0, "pos", "neg"),
			sign_avgKHS_skew_pred_base = ifelse(avgKHS_skew_pred_base > 0, "pos", "neg")
		) %>% 
		mutate(
			K562_pos_skew_pred_base = ifelse(sign_K562_skew_pred_base == "pos", K562_skew_pred_base, NA), 
			HepG2_pos_skew_pred_base = ifelse(sign_HepG2_skew_pred_base == "pos", HepG2_skew_pred_base, NA), 
			SKNSH_pos_skew_pred_base = ifelse(sign_SKNSH_skew_pred_base == "pos", SKNSH_skew_pred_base, NA), 
			avgKHS_pos_skew_pred_base = ifelse(sign_avgKHS_skew_pred_base == "pos", avgKHS_skew_pred_base, NA), 

			K562_neg_skew_pred_base = ifelse(sign_K562_skew_pred_base == "neg", K562_skew_pred_base, NA), 
			HepG2_neg_skew_pred_base = ifelse(sign_HepG2_skew_pred_base == "neg", HepG2_skew_pred_base, NA), 
			SKNSH_neg_skew_pred_base = ifelse(sign_SKNSH_skew_pred_base == "neg", SKNSH_skew_pred_base, NA), 
			avgKHS_neg_skew_pred_base = ifelse(sign_avgKHS_skew_pred_base == "neg", avgKHS_skew_pred_base, NA), 
		) %>% 
		ungroup() %>% 
		dplyr::select(-sign_K562_skew_pred_base, -sign_HepG2_skew_pred_base, -sign_SKNSH_skew_pred_base, -sign_avgKHS_skew_pred_base)

	# save all base-level
	write_tsv(satmut_promoters_final_base, gzfile(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_final_base/satmut_promoters_final_base_", chr, ".txt.gz")))
}
