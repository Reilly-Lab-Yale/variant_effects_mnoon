#!/bin/R

# Get distance level predictions

library(tidyverse)
library(data.table)

# dist-level data
satmut_promoters_final_dist_list <- list()
for (chr in paste0("chr", c(22:1))) {
	print(chr)
	satmut_promoters_final_temp <- as_tibble(fread(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_final/satmut_promoters_final_", chr, ".txt.gz")))
	satmut_promoters_final_dist_temp <- satmut_promoters_final_temp %>% 
		filter(!in_all_exon_splice) %>% 
		group_by(
			tss_dist, 
			in_promoter_1kb, 
			in_promoter_750bp, 
			in_promoter_500bp, 
			in_promoter_250bp,
			) %>% 
			summarise(
				n_in_tss_dist = n(),

				K562_ref_pred = sum(K562_ref_pred, na.rm=T), 
				HepG2_ref_pred = sum(HepG2_ref_pred, na.rm=T), 
				SKNSH_ref_pred = sum(SKNSH_ref_pred, na.rm=T), 
				avgKHS_ref_pred = sum(avgKHS_ref_pred, na.rm=T), 

				K562_alt_pred = sum(K562_alt_pred, na.rm=T), 
				HepG2_alt_pred = sum(HepG2_alt_pred, na.rm=T), 
				SKNSH_alt_pred = sum(SKNSH_alt_pred, na.rm=T), 
				avgKHS_alt_pred = sum(avgKHS_alt_pred, na.rm=T), 
			
				K562_skew_pred = sum(K562_skew_pred, na.rm=T), 
				HepG2_skew_pred = sum(HepG2_skew_pred, na.rm=T), 
				SKNSH_skew_pred = sum(SKNSH_skew_pred, na.rm=T), 
				avgKHS_skew_pred = sum(avgKHS_skew_pred, na.rm=T), 

				K562_activity_pred = sum(K562_activity_pred, na.rm=T), 
				HepG2_activity_pred = sum(HepG2_activity_pred, na.rm=T), 
				SKNSH_activity_pred = sum(SKNSH_activity_pred, na.rm=T), 
				avgKHS_activity_pred = sum(avgKHS_activity_pred, na.rm=T), 
			
				K562_abs_skew_pred = sum(K562_abs_skew_pred, na.rm=T), 
				HepG2_abs_skew_pred = sum(HepG2_abs_skew_pred, na.rm=T), 
				SKNSH_abs_skew_pred = sum(SKNSH_abs_skew_pred, na.rm=T), 
				avgKHS_abs_skew_pred = sum(avgKHS_abs_skew_pred, na.rm=T), 

				phyloP_mam241 = sum(phyloP_mam241, na.rm=T), 
				# phyloP_pri243 = sum(phyloP_pri243, na.rm=T), 
				# phyloP_mam447 = sum(phyloP_mam447, na.rm=T), 

				CADD_Roulette_MR = mean(CADD_Roulette_MR, na.rm=T),
				CADD_PHRED = mean(CADD_PHRED, na.rm=T),
			) %>% 
			ungroup()

	satmut_promoters_final_dist_list[[chr]] <- satmut_promoters_final_dist_temp
}

satmut_promoters_final_dist_all <- satmut_promoters_final_dist_list %>% bind_rows() %>% 
	group_by(
		tss_dist, 
		in_promoter_1kb, 
		in_promoter_750bp, 
		in_promoter_500bp, 
		in_promoter_250bp
		) %>% 
		summarise(
			n_in_tss_dist = sum(n_in_tss_dist, na.rm=T),

			K562_ref_pred_dist = sum(K562_ref_pred, na.rm=T), 
			HepG2_ref_pred_dist = sum(HepG2_ref_pred, na.rm=T), 
			SKNSH_ref_pred_dist = sum(SKNSH_ref_pred, na.rm=T), 
			avgKHS_ref_pred_dist = sum(avgKHS_ref_pred, na.rm=T), 

			K562_alt_pred_dist = sum(K562_alt_pred, na.rm=T), 
			HepG2_alt_pred_dist = sum(HepG2_alt_pred, na.rm=T), 
			SKNSH_alt_pred_dist = sum(SKNSH_alt_pred, na.rm=T), 
			avgKHS_alt_pred_dist = sum(avgKHS_alt_pred, na.rm=T), 
		
			K562_skew_pred_dist = sum(K562_skew_pred, na.rm=T), 
			HepG2_skew_pred_dist = sum(HepG2_skew_pred, na.rm=T), 
			SKNSH_skew_pred_dist = sum(SKNSH_skew_pred, na.rm=T), 
			avgKHS_skew_pred_dist = sum(avgKHS_skew_pred, na.rm=T), 

			K562_activity_pred_dist = sum(K562_activity_pred, na.rm=T), 
			HepG2_activity_pred_dist = sum(HepG2_activity_pred, na.rm=T), 
			SKNSH_activity_pred_dist = sum(SKNSH_activity_pred, na.rm=T), 
			avgKHS_activity_pred_dist = sum(avgKHS_activity_pred, na.rm=T), 
		
			K562_abs_skew_pred_dist = sum(K562_abs_skew_pred, na.rm=T), 
			HepG2_abs_skew_pred_dist = sum(HepG2_abs_skew_pred, na.rm=T), 
			SKNSH_abs_skew_pred_dist = sum(SKNSH_abs_skew_pred, na.rm=T), 
			avgKHS_abs_skew_pred_dist = sum(avgKHS_abs_skew_pred, na.rm=T), 

			phyloP_mam241_dist = sum(phyloP_mam241, na.rm=T), 
			# phyloP_pri243_dist = sum(phyloP_pri243, na.rm=T), 
			# phyloP_mam447_dist = sum(phyloP_mam447, na.rm=T), 

			CADD_Roulette_MR_dist = sum(CADD_Roulette_MR, na.rm=T),
			CADD_PHRED_dist = sum(CADD_PHRED, na.rm=T),
		) %>% 
		mutate(
			K562_ref_pred_dist = K562_ref_pred_dist/n_in_tss_dist,
			HepG2_ref_pred_dist = HepG2_ref_pred_dist/n_in_tss_dist,
			SKNSH_ref_pred_dist = SKNSH_ref_pred_dist/n_in_tss_dist,
			avgKHS_ref_pred_dist = avgKHS_ref_pred_dist/n_in_tss_dist,

			K562_alt_pred_dist = K562_alt_pred_dist/n_in_tss_dist,
			HepG2_alt_pred_dist = HepG2_alt_pred_dist/n_in_tss_dist,
			SKNSH_alt_pred_dist = SKNSH_alt_pred_dist/n_in_tss_dist,
			avgKHS_alt_pred_dist = avgKHS_alt_pred_dist/n_in_tss_dist,
		
			K562_skew_pred_dist = K562_skew_pred_dist/n_in_tss_dist,
			HepG2_skew_pred_dist = HepG2_skew_pred_dist/n_in_tss_dist,
			SKNSH_skew_pred_dist = SKNSH_skew_pred_dist/n_in_tss_dist,
			avgKHS_skew_pred_dist = avgKHS_skew_pred_dist/n_in_tss_dist,

			K562_activity_pred_dist = K562_activity_pred_dist/n_in_tss_dist,
			HepG2_activity_pred_dist = HepG2_activity_pred_dist/n_in_tss_dist,
			SKNSH_activity_pred_dist = SKNSH_activity_pred_dist/n_in_tss_dist,
			avgKHS_activity_pred_dist = avgKHS_activity_pred_dist/n_in_tss_dist,
		
			K562_abs_skew_pred_dist = K562_abs_skew_pred_dist/n_in_tss_dist,
			HepG2_abs_skew_pred_dist = HepG2_abs_skew_pred_dist/n_in_tss_dist,
			SKNSH_abs_skew_pred_dist = SKNSH_abs_skew_pred_dist/n_in_tss_dist,
			avgKHS_abs_skew_pred_dist = avgKHS_abs_skew_pred_dist/n_in_tss_dist,

			phyloP_mam241_dist = phyloP_mam241_dist/n_in_tss_dist,
			# phyloP_pri243_dist = phyloP_pri243_dist/n_in_tss_dist,
			# phyloP_mam447_dist = phyloP_mam447_dist/n_in_tss_dist,

			CADD_Roulette_MR_dist = CADD_Roulette_MR_dist/n_in_tss_dist,
			CADD_PHRED_dist = CADD_PHRED_dist/n_in_tss_dist,
		) %>% 
		ungroup()	

write_tsv(satmut_promoters_final_dist_all, gzfile(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_final_dist/satmut_promoters_final_dist_all.txt.gz")))
