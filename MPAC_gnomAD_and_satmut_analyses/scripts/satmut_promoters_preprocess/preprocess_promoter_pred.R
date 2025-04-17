#!/bin/R

# Process predictions and add in emVar annotations and promoter/masked regions

# load libraries
library(data.table)
library(tidyverse)
library(stringi)

# load bioconductor
library(plyranges)
library(rtracklayer)

# load promoter/exon data
satmut_promoters_promoter_regions_1kb <- readRDS("../../results/satmut_promoters_preprocess/satmut_promoters_regions/satmut_promoters_promoter_regions_1kb.rds")
satmut_promoters_promoter_regions_750bp <- readRDS("../../results/satmut_promoters_preprocess/satmut_promoters_regions/satmut_promoters_promoter_regions_750bp.rds")
satmut_promoters_promoter_regions_500bp <- readRDS("../../results/satmut_promoters_preprocess/satmut_promoters_regions/satmut_promoters_promoter_regions_500bp.rds")
satmut_promoters_promoter_regions_250bp <- readRDS("../../results/satmut_promoters_preprocess/satmut_promoters_regions/satmut_promoters_promoter_regions_250bp.rds")
satmut_promoters_promoter_regions_tss <- readRDS("../../results/satmut_promoters_preprocess/satmut_promoters_regions/satmut_promoters_promoter_regions_tss.rds")

satmut_promoters_exon_regions <- rtracklayer::import("../../data/gencode_filtered_regions/gencode.v44.protein.coding.exons.autosomes.v2.bed")
satmut_promoters_exon_splice_regions <- rtracklayer::import("../../data/gencode_filtered_regions/gencode.v44.protein.coding.exons.splice.autosomes.v2.bed")
satmut_promoters_all_exon_regions <- rtracklayer::import("../../data/gencode_filtered_regions/gencode.v44.basic.annotation.exons.autosomes.v2.bed")
satmut_promoters_all_exon_splice_regions <- rtracklayer::import("../../data/gencode_filtered_regions/gencode.v44.basic.annotation.exons.splice.autosomes.v2.bed")

# loop chromosomes
for (chr in paste0("chr", c(22:1))) {
	print(chr)

	# load predictions
	satmut_promoters_pred <- as_tibble(fread(paste0("../../data/satmut_promoters_predictions/gencode.v44.canonical.protein.coding.1kb.promoters.sat.mut.updated.pos.", chr, ".vcf.gz")))
	mpac_cols <- c("K562_ref_pred", "HepG2_ref_pred", "SKNSH_ref_pred", "K562_alt_pred", "HepG2_alt_pred", "SKNSH_alt_pred", "K562_skew_pred", "HepG2_skew_pred", "SKNSH_skew_pred")
	satmut_promoters_pred <- satmut_promoters_pred %>% 
		mutate(INFO = stri_split_fixed(INFO, ";")) %>% unnest(INFO) %>% mutate(INFO = as.numeric(gsub(".*=", "", INFO))) %>% 
		(function(x) {x$TEMP <- rep(mpac_cols, nrow(x)/length(mpac_cols)); return(x)})(.) %>% pivot_wider(names_from="TEMP", values_from=INFO)

	# clean up formating
	satmut_promoters_pred <- satmut_promoters_pred %>% 
		mutate(id = gsub("\\.\\..*", "", id))
	satmut_promoters_pred <- satmut_promoters_pred %>% 
		distinct()  # gets rid of repeats due to original bed file used for prediction containing multiple promoters of some genes

	# get strand  # and flip ref and alt
	satmut_promoters_promoter_regions_1kb_strand <- satmut_promoters_promoter_regions_1kb %>% 
		as_tibble() %>% 
		dplyr::select(id, strand)

	satmut_promoters_pred <- satmut_promoters_pred %>% 
		left_join(satmut_promoters_promoter_regions_1kb_strand)

	# get distance to tss for meta promoters
	satmut_promoters_promoter_regions_tss_pos <- satmut_promoters_promoter_regions_tss %>% 
		as_tibble() %>% 
		mutate(tss = ifelse(strand == "+", start, end)) %>% 
		dplyr::select(id, tss)

	satmut_promoters_pred <- satmut_promoters_pred %>% 
		left_join(satmut_promoters_promoter_regions_tss_pos) %>% 
		mutate(tss_dist = ifelse(strand == "+", pos - tss, tss - pos)) %>% 
		dplyr::select(-tss)

	# get final columns
	satmut_promoters_pred <- satmut_promoters_pred %>% 
		dplyr::select(chrom, pos, ref, alt, id, strand, tss_dist, everything())  # , ref_orig, alt_orig, everything())

	# get emVar summaries
	satmut_promoters_pred <- satmut_promoters_pred %>% 
		# activity - temp
		mutate(
			K562_activity_pred = pmax(K562_ref_pred, K562_alt_pred),
			HepG2_activity_pred = pmax(HepG2_ref_pred, HepG2_alt_pred),
			SKNSH_activity_pred = pmax(SKNSH_ref_pred, SKNSH_alt_pred)
		) %>% 
		# abs skew
		mutate(
			K562_abs_skew_pred = abs(K562_skew_pred),
			HepG2_abs_skew_pred = abs(HepG2_skew_pred),
			SKNSH_abs_skew_pred = abs(SKNSH_skew_pred)
		) %>% 
		# mean activity
		mutate(
			avgKHS_ref_pred = (K562_ref_pred+HepG2_ref_pred+SKNSH_ref_pred)/3, 
			avgKHS_alt_pred = (K562_alt_pred+HepG2_alt_pred+SKNSH_alt_pred)/3, 
			avgKHS_skew_pred = (K562_skew_pred+HepG2_skew_pred+SKNSH_skew_pred)/3, 
			avgKHS_activity_pred = (K562_activity_pred+HepG2_activity_pred+SKNSH_activity_pred)/3, 
			avgKHS_abs_skew_pred = (K562_abs_skew_pred+HepG2_abs_skew_pred+SKNSH_abs_skew_pred)/3, 
		) %>% 
		# active
		mutate(
			K562_active = (K562_activity_pred >= 1), 
			HepG2_active = (HepG2_activity_pred >= 1), 
			SKNSH_active = (SKNSH_activity_pred >= 1),
			avgKHS_active = (avgKHS_activity_pred >= 1),
		) %>% 
		mutate(
			anyKHS_active = (K562_active | HepG2_active | avgKHS_active)
		) %>% 
		# emVars
		mutate(
			K562_emVar = ((K562_abs_skew_pred >= 0.5) & K562_active), 
			HepG2_emVar = ((HepG2_abs_skew_pred >= 0.5) & HepG2_active), 
			SKNSH_emVar = ((SKNSH_abs_skew_pred >= 0.5) & SKNSH_active), 
			avgKHS_emVar = ((avgKHS_abs_skew_pred >= 0.5) & avgKHS_active), 
		) %>% 
		mutate(
			anyKHS_emVar = (K562_emVar | HepG2_emVar | avgKHS_emVar)
		) %>% 
		# emVars pos
		mutate(
			K562_emVar_pos = ((K562_skew_pred >= 0.5) & K562_active), 
			HepG2_emVar_pos = ((HepG2_skew_pred >= 0.5) & HepG2_active), 
			SKNSH_emVar_pos = ((SKNSH_skew_pred >= 0.5) & SKNSH_active),
			avgKHS_emVar_pos = ((avgKHS_skew_pred >= 0.5) & avgKHS_active)
		) %>% 
		mutate(
			anyKHS_emVar_pos = (K562_emVar_pos | HepG2_emVar_pos | avgKHS_emVar_pos),
		) %>% 
		# emVars neg
		mutate(
			K562_emVar_neg = ((K562_skew_pred <= -0.5) & K562_active), 
			HepG2_emVar_neg = ((HepG2_skew_pred <= -0.5) & HepG2_active), 
			SKNSH_emVar_neg = ((SKNSH_skew_pred <= -0.5) & SKNSH_active), 
			avgKHS_emVar_neg = ((avgKHS_skew_pred <= -0.5) & avgKHS_active), 
		) %>% 
		mutate(
			anyKHS_emVar_neg = (K562_emVar_neg | HepG2_emVar_neg | avgKHS_emVar_neg)
		) %>% 
		# pleiotropy
		mutate(active_category = 
			case_when(
				K562_active & SKNSH_active & HepG2_active ~ "K562+SKNSH+HepG2 active",
				K562_active & SKNSH_active ~ "K562+SKNSH active",
				K562_active & HepG2_active ~ "K562+HepG2 active",
				SKNSH_active & HepG2_active ~ "SKNSH+HepG2 active",
				K562_active ~ "K562 active",
				HepG2_active ~ "HepG2 active",
				SKNSH_active ~ "SKNSH active",
				.default = "none"
			)
		) %>% 
		mutate(emVar_category = 
			case_when(
				K562_emVar & SKNSH_emVar & HepG2_emVar ~ "K562+SKNSH+HepG2 emVar",
				K562_emVar & SKNSH_emVar ~ "K562+SKNSH emVar",
				K562_emVar & HepG2_emVar ~ "K562+HepG2 emVar",
				SKNSH_emVar & HepG2_emVar ~ "SKNSH+HepG2 emVar",
				K562_emVar ~ "K562 emVar",
				HepG2_emVar ~ "HepG2 emVar",
				SKNSH_emVar ~ "SKNSH emVar",
				.default = "none"
			)
		) %>% 
		mutate(
			active_count = (K562_active + HepG2_active + SKNSH_active), 
			emVar_count = (K562_emVar + HepG2_emVar + SKNSH_emVar)
		)

	# get promoter overlap
	overlap_promoter_1kb <- as_tibble(satmut_promoters_promoter_regions_1kb) %>% 
		mutate(chrom = seqnames) %>%  # , id = name) %>% 
		dplyr::select(chrom, start, end, id)
	overlap_promoter_regions_750bp <- as_tibble(satmut_promoters_promoter_regions_750bp) %>% 
		mutate(chrom = seqnames) %>%  # , id = name) %>% 
		dplyr::select(chrom, start, end, id)
	overlap_promoter_regions_500bp <- as_tibble(satmut_promoters_promoter_regions_500bp) %>% 
		mutate(chrom = seqnames) %>%  # , id = name) %>% 
		dplyr::select(chrom, start, end, id)
	overlap_promoter_regions_250bp <- as_tibble(satmut_promoters_promoter_regions_250bp) %>% 
		mutate(chrom = seqnames) %>%  # , id = name) %>% 
		dplyr::select(chrom, start, end, id)

	satmut_promoters_pred <- satmut_promoters_pred %>% 
		left_join(overlap_promoter_1kb) %>% 
		mutate(in_promoter_1kb = ((pos >= start) & (pos <= end))) %>% 
		dplyr::select(-start, -end)

	satmut_promoters_pred <- satmut_promoters_pred %>% 
		left_join(overlap_promoter_regions_750bp) %>% 
		mutate(in_promoter_750bp = ((pos >= start) & (pos <= end))) %>% 
		dplyr::select(-start, -end)

	satmut_promoters_pred <- satmut_promoters_pred %>% 
		left_join(overlap_promoter_regions_500bp) %>% 
		mutate(in_promoter_500bp = ((pos >= start) & (pos <= end))) %>% 
		dplyr::select(-start, -end)

	satmut_promoters_pred <- satmut_promoters_pred %>% 
		left_join(overlap_promoter_regions_250bp) %>% 
		mutate(in_promoter_250bp = ((pos >= start) & (pos <= end))) %>% 
		dplyr::select(-start, -end)

	# remove first base of exon
	satmut_promoters_pred <- satmut_promoters_pred %>% 
		filter(in_promoter_1kb)

	# get promoter quartile
	satmut_promoters_pred <- satmut_promoters_pred %>% 
		mutate(in_promoter_quartile = 
			ifelse(in_promoter_250bp, "in_promoter_250bp", 
				ifelse(in_promoter_500bp, "in_promoter_500bp", 
					ifelse(in_promoter_750bp, "in_promoter_750bp", 
						ifelse(in_promoter_1kb, "in_promoter_1kb", NA)))))

	# get exon overlap
	satmut_promoters_pred_gr <- satmut_promoters_pred %>% 
		mutate(start = pos, end = pos) %>% 
		GRanges()

	overlap_all_exon_regions <- queryHits(findOverlaps(satmut_promoters_pred_gr, satmut_promoters_all_exon_regions))
	satmut_promoters_pred <- satmut_promoters_pred %>% 
		mutate(in_all_exon = (row_number() %in% overlap_all_exon_regions))

	overlap_all_exon_splice_regions <- queryHits(findOverlaps(satmut_promoters_pred_gr, satmut_promoters_all_exon_splice_regions))
	satmut_promoters_pred <- satmut_promoters_pred %>% 
		mutate(in_all_exon_splice = (row_number() %in% overlap_all_exon_splice_regions))

	# rearrange
	satmut_promoters_pred <- satmut_promoters_pred %>% 
		dplyr::select(
			chrom, pos, ref, alt, id, strand, tss_dist, starts_with("in_"), 
			starts_with("K562_"), starts_with("HepG2_"), starts_with("SKNSH_"), 
			starts_with("avgKHS_"), everything()
		)

	# save predictions
	write_tsv(satmut_promoters_pred, gzfile(paste0("../../results/satmut_promoters_preprocess/satmut_promoters_pred/satmut_promoters_pred_", chr, ".txt.gz")))
}
