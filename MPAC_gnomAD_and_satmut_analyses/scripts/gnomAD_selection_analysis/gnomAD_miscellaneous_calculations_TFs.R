#!/bin/R

library(tidyverse)
library(data.table)

# get counts overlap with TF ChIP-seq
gnomAD_TF_ChIP_seq_list <- NULL

for (i in paste0("chr", 1:22)) {
	print(paste0("processing ", i))
	gnomAD_TF_ChIP_seq_chr <- fread(paste0("tabix ../../data/MPAC_gnomAD_variants_filtered/gnomad.genomes.v3.1.2.sites.", i, ".filtered.vcf.gz -R ../../data/gnomAD_miscellaneous/tf_chip_seq/chip.for.steve.regions.hg38.bed  | sed 's/;/\t/g' | awk '{print $1, $2, $4, $5, $(NF-8), $(NF-7), $(NF-6), $(NF-5), $(NF-4), $(NF-3), $(NF-2), $(NF-1), $NF}' OFS='\t' | sed -E 's/(K562__ref=|HepG2__ref=|SKNSH__ref=|K562__alt=|HepG2__alt=|SKNSH__alt=|K562__skew=|HepG2__skew=|SKNSH__skew=)//g'"))
	names(gnomAD_TF_ChIP_seq_chr) <- c("chr", "pos", "ref", "alt", "K562_ref", "HepG2_ref", "SKNSH_ref", "K562_alt", "HepG2_alt", "SKNSH_alt", "K562_skew", "HepG2_skew", "SKNSH_skew")

	gnomAD_TF_ChIP_seq_temp <- gnomAD_TF_ChIP_seq_chr %>% 
		mutate(
			mean_skew = (K562_skew + HepG2_skew + SKNSH_skew)/3, 
			count = 1
		) %>% 
		mutate(mean_skew_pred_bin = cut(mean_skew, 
			breaks = c(-Inf, -1.5, -1.0, -0.5, -0.2, -0.05, 0.05, 0.2, 0.5, 1.0, 1.5, Inf), 
			labels = c("(-Inf, -1.5)", "[-1.5, -1.0)", "[-1.0, -0.5)", "[-0.5, -0.2)", 
				"[-0.2, -0.05)", "[-0.05, 0.05)", "[0.05, 0.2)", "[0.2, 0.5)", 
				"[0.5, 1.0)", "[1.0, 1.5)", "[1.5, Inf)"), 
			right = FALSE)
		) %>% 
		dplyr::select(mean_skew_pred_bin, count) %>% 
		group_by(mean_skew_pred_bin) %>% 
		summarise(
			count = sum(count)
		) %>% 
		ungroup()

	gnomAD_TF_ChIP_seq_list[[i]] <- gnomAD_TF_ChIP_seq_temp

	print(gnomAD_TF_ChIP_seq_list)
}

gnomAD_TF_ChIP_seq_mean_allelic_skew <- gnomAD_TF_ChIP_seq_list %>% 
	bind_rows(.id = "cCRE") %>% 
	group_by(mean_skew_pred_bin) %>% 
	summarise(
		count = sum(count)
	) %>% 
	ungroup()

# get counts overlap with TF ChIP-seq
gnomAD_noChIP_list <- NULL

for (i in paste0("chr", 1:22)) {
	print(paste0("processing ", i))
	gnomAD_noChIP_chr <- fread(paste0("tabix ../../data/MPAC_gnomAD_variants_filtered/gnomad.genomes.v3.1.2.sites.", i, ".filtered.vcf.gz -R ../../data/gnomAD_miscellaneous/tf_chip_seq/chip.for.steve.complement.hg38.bed  | sed 's/;/\t/g' | awk '{print $1, $2, $4, $5, $(NF-8), $(NF-7), $(NF-6), $(NF-5), $(NF-4), $(NF-3), $(NF-2), $(NF-1), $NF}' OFS='\t' | sed -E 's/(K562__ref=|HepG2__ref=|SKNSH__ref=|K562__alt=|HepG2__alt=|SKNSH__alt=|K562__skew=|HepG2__skew=|SKNSH__skew=)//g'"))
	names(gnomAD_noChIP_chr) <- c("chr", "pos", "ref", "alt", "K562_ref", "HepG2_ref", "SKNSH_ref", "K562_alt", "HepG2_alt", "SKNSH_alt", "K562_skew", "HepG2_skew", "SKNSH_skew")

	gnomAD_noChIP_temp <- gnomAD_noChIP_chr %>% 
		mutate(
			mean_skew = (K562_skew + HepG2_skew + SKNSH_skew)/3, 
			count = 1
		) %>% 
		mutate(mean_skew_pred_bin = cut(mean_skew, 
			breaks = c(-Inf, -1.5, -1.0, -0.5, -0.2, -0.05, 0.05, 0.2, 0.5, 1.0, 1.5, Inf), 
			labels = c("(-Inf, -1.5)", "[-1.5, -1.0)", "[-1.0, -0.5)", "[-0.5, -0.2)", 
				"[-0.2, -0.05)", "[-0.05, 0.05)", "[0.05, 0.2)", "[0.2, 0.5)", 
				"[0.5, 1.0)", "[1.0, 1.5)", "[1.5, Inf)"), 
			right = FALSE)
		) %>% 
		dplyr::select(mean_skew_pred_bin, count) %>% 
		group_by(mean_skew_pred_bin) %>% 
		summarise(
			count = sum(count)
		) %>% 
		ungroup()

	gnomAD_noChIP_list[[i]] <- gnomAD_noChIP_temp

	print(gnomAD_noChIP_list)
}

gnomAD_noChIP_mean_allelic_skew <- gnomAD_noChIP_list %>% 
	bind_rows(.id = "cCRE") %>% 
	group_by(mean_skew_pred_bin) %>% 
	summarise(
		count = sum(count)
	) %>% 
	ungroup()

gnomAD_TF_ChIP_seq_mean_allelic_skew <- bind_rows(
	gnomAD_TF_ChIP_seq_mean_allelic_skew %>% mutate(TF_ChIP_seq = TRUE) %>% dplyr::select(TF_ChIP_seq, everything()), 
	gnomAD_noChIP_mean_allelic_skew %>% mutate(TF_ChIP_seq = FALSE) %>% dplyr::select(TF_ChIP_seq, everything()), 
)

print(gnomAD_TF_ChIP_seq_mean_allelic_skew)

write_tsv(gnomAD_TF_ChIP_seq_mean_allelic_skew, "../../results/gnomAD_selection_analysis/gnomAD_TF_ChIP_seq_mean_allelic_skew.txt")


# get counts overlap with TF footprints
gnomAD_TF_footprints_list <- NULL

for (i in paste0("chr", 1:22)) {
	print(paste0("processing ", i))
	gnomAD_TF_footprints_chr <- fread(paste0("tabix ../../data/MPAC_gnomAD_variants_filtered/gnomad.genomes.v3.1.2.sites.", i, ".filtered.vcf.gz -R ../../data/gnomAD_miscellaneous/tf_footprints/tf.footprints.regions.bed | sed 's/;/\t/g' | awk '{print $1, $2, $4, $5, $(NF-8), $(NF-7), $(NF-6), $(NF-5), $(NF-4), $(NF-3), $(NF-2), $(NF-1), $NF}' OFS='\t' | sed -E 's/(K562__ref=|HepG2__ref=|SKNSH__ref=|K562__alt=|HepG2__alt=|SKNSH__alt=|K562__skew=|HepG2__skew=|SKNSH__skew=)//g'"))
	names(gnomAD_TF_footprints_chr) <- c("chr", "pos", "ref", "alt", "K562_ref", "HepG2_ref", "SKNSH_ref", "K562_alt", "HepG2_alt", "SKNSH_alt", "K562_skew", "HepG2_skew", "SKNSH_skew")

	gnomAD_TF_footprints_temp <- gnomAD_TF_footprints_chr %>% 
		mutate(
			mean_skew = (K562_skew + HepG2_skew + SKNSH_skew)/3, 
			count = 1
		) %>% 
		mutate(mean_skew_pred_bin = cut(mean_skew, 
			breaks = c(-Inf, -1.5, -1.0, -0.5, -0.2, -0.05, 0.05, 0.2, 0.5, 1.0, 1.5, Inf), 
			labels = c("(-Inf, -1.5)", "[-1.5, -1.0)", "[-1.0, -0.5)", "[-0.5, -0.2)", 
				"[-0.2, -0.05)", "[-0.05, 0.05)", "[0.05, 0.2)", "[0.2, 0.5)", 
				"[0.5, 1.0)", "[1.0, 1.5)", "[1.5, Inf)"), 
			right = FALSE)
		) %>% 
		dplyr::select(mean_skew_pred_bin, count) %>% 
		group_by(mean_skew_pred_bin) %>% 
		summarise(
			count = sum(count)
		) %>% 
		ungroup()

	gnomAD_TF_footprints_list[[i]] <- gnomAD_TF_footprints_temp

	print(gnomAD_TF_footprints_list)
}

gnomAD_TF_footprints_mean_allelic_skew <- gnomAD_TF_footprints_list %>% 
	bind_rows(.id = "cCRE") %>% 
	group_by(mean_skew_pred_bin) %>% 
	summarise(
		count = sum(count)
	) %>% 
	ungroup()

# get counts overlap with TF TF_footprints-seq
gnomAD_noTF_footprints_list <- NULL

for (i in paste0("chr", 1:22)) {
	print(paste0("processing ", i))
	gnomAD_noTF_footprints_chr <- fread(paste0("tabix ../../data/MPAC_gnomAD_variants_filtered/gnomad.genomes.v3.1.2.sites.", i, ".filtered.vcf.gz -R ../../data/gnomAD_miscellaneous/tf_footprints/tf.footprints.complement.bed | sed 's/;/\t/g' | awk '{print $1, $2, $4, $5, $(NF-8), $(NF-7), $(NF-6), $(NF-5), $(NF-4), $(NF-3), $(NF-2), $(NF-1), $NF}' OFS='\t' | sed -E 's/(K562__ref=|HepG2__ref=|SKNSH__ref=|K562__alt=|HepG2__alt=|SKNSH__alt=|K562__skew=|HepG2__skew=|SKNSH__skew=)//g'"))
	names(gnomAD_noTF_footprints_chr) <- c("chr", "pos", "ref", "alt", "K562_ref", "HepG2_ref", "SKNSH_ref", "K562_alt", "HepG2_alt", "SKNSH_alt", "K562_skew", "HepG2_skew", "SKNSH_skew")

	gnomAD_noTF_footprints_temp <- gnomAD_noTF_footprints_chr %>% 
		mutate(
			mean_skew = (K562_skew + HepG2_skew + SKNSH_skew)/3, 
			count = 1
		) %>% 
		mutate(mean_skew_pred_bin = cut(mean_skew, 
			breaks = c(-Inf, -1.5, -1.0, -0.5, -0.2, -0.05, 0.05, 0.2, 0.5, 1.0, 1.5, Inf), 
			labels = c("(-Inf, -1.5)", "[-1.5, -1.0)", "[-1.0, -0.5)", "[-0.5, -0.2)", 
				"[-0.2, -0.05)", "[-0.05, 0.05)", "[0.05, 0.2)", "[0.2, 0.5)", 
				"[0.5, 1.0)", "[1.0, 1.5)", "[1.5, Inf)"), 
			right = FALSE)
		) %>% 
		dplyr::select(mean_skew_pred_bin, count) %>% 
		group_by(mean_skew_pred_bin) %>% 
		summarise(
			count = sum(count)
		) %>% 
		ungroup()

	gnomAD_noTF_footprints_list[[i]] <- gnomAD_noTF_footprints_temp

	print(gnomAD_noTF_footprints_list)
}

gnomAD_noTF_footprints_mean_allelic_skew <- gnomAD_noTF_footprints_list %>% 
	bind_rows(.id = "cCRE") %>% 
	group_by(mean_skew_pred_bin) %>% 
	summarise(
		count = sum(count)
	) %>% 
	ungroup()

gnomAD_TF_footprints_mean_allelic_skew <- bind_rows(
	gnomAD_TF_footprints_mean_allelic_skew %>% mutate(TF_footprints = TRUE) %>% dplyr::select(TF_footprints, everything()), 
	gnomAD_noTF_footprints_mean_allelic_skew %>% mutate(TF_footprints = FALSE) %>% dplyr::select(TF_footprints, everything()), 
)

print(gnomAD_TF_footprints_mean_allelic_skew)

write_tsv(gnomAD_TF_footprints_mean_allelic_skew, "../../results/gnomAD_selection_analysis/gnomAD_TF_footprints_mean_allelic_skew.txt")
