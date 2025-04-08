#!/bin/R

library(tidyverse)
library(data.table)

# get mean predictions in each CRE category
gnomAD_cCRE_list <- NULL

for (j in c("PLS", "pELS", "dELS", "DNase-low")) {
	print(paste0("Processing ", j))
	gnomAD_chr_list <- NULL
	for (i in paste0("chr", 1:22)) {
		print(paste0("processing ", i))
		gnomAD_chr <- fread(paste0("tabix ../../data/MPAC_gnomAD_variants_filtered/gnomad.genomes.v3.1.2.sites.", i, ".filtered.vcf.gz -R ../../data/gene_regulation_element_catalogs/GRCh38-", j, ".V4.bed.gz | sed 's/;/\t/g' | awk '{print $1, $2, $4, $5, $(NF-8), $(NF-7), $(NF-6), $(NF-5), $(NF-4), $(NF-3), $(NF-2), $(NF-1), $NF}' OFS='\t' | sed -E 's/(K562__ref=|HepG2__ref=|SKNSH__ref=|K562__alt=|HepG2__alt=|SKNSH__alt=|K562__skew=|HepG2__skew=|SKNSH__skew=)//g'"))
		names(gnomAD_chr) <- c("chr", "pos", "ref", "alt", "K562_ref", "HepG2_ref", "SKNSH_ref", "K562_alt", "HepG2_alt", "SKNSH_alt", "K562_skew", "HepG2_skew", "SKNSH_skew")

		gnomAD_chr_sums <- gnomAD_chr %>% 
			mutate(
				K562_abs_skew = abs(K562_skew), 
				HepG2_abs_skew = abs(HepG2_skew), 
				SKNSH_abs_skew = abs(SKNSH_skew), 
				mean_ref = (K562_ref + HepG2_ref + SKNSH_ref)/3, 
				mean_alt = (K562_alt + HepG2_alt + SKNSH_alt)/3, 
				mean_skew = (K562_skew + HepG2_skew + SKNSH_skew)/3, 
				mean_abs_skew = (K562_abs_skew + HepG2_abs_skew + SKNSH_abs_skew)/3, 
				count = 1) %>% 
			dplyr::select(-chr, -pos, -ref, -alt) %>% 
			colSums()

		gnomAD_chr_list[[i]] <- gnomAD_chr_sums

		print(gnomAD_chr_list)
	}

	gnomAD_cCRE_sums <- gnomAD_chr_list %>% 
		bind_rows() %>% 
		colSums()

	temp <- length(gnomAD_cCRE_sums)
	gnomAD_cCRE_means <- (gnomAD_cCRE_sums[1:(temp-1)]/gnomAD_cCRE_sums[temp]) %>% 
		t() %>% as_tibble()

	gnomAD_cCRE_list[[j]] <- gnomAD_cCRE_means

	print(gnomAD_cCRE_list)
}

gnomAD_cCRE_means <- gnomAD_cCRE_list %>% 
	bind_rows(.id = "cCRE") %>% 
	mutate(cCRE = ifelse(cCRE == "DNase-low", "non-cCRE", cCRE))

print(gnomAD_cCRE_means)

write_tsv(gnomAD_cCRE_means, "../../results/gnomAD_selection_analysis/gnomAD_mean_pred_per_encode_ccre.txt")


# get mean predictions genome-wide
gnomAD_chr_list <- NULL
for (i in paste0("chr", 1:22)) {
	print(paste0("processing ", i))
	gnomAD_chr <- fread(paste0("gunzip -cd ../../data/MPAC_gnomAD_variants_filtered/gnomad.genomes.v3.1.2.sites.", i, ".filtered.vcf.gz | sed 's/;/\t/g' | tail -n +2 | awk '{print $1, $2, $4, $5, $(NF-8), $(NF-7), $(NF-6), $(NF-5), $(NF-4), $(NF-3), $(NF-2), $(NF-1), $NF}' OFS='\t' | sed -E 's/(K562__ref=|HepG2__ref=|SKNSH__ref=|K562__alt=|HepG2__alt=|SKNSH__alt=|K562__skew=|HepG2__skew=|SKNSH__skew=)//g'"))
	names(gnomAD_chr) <- c("chr", "pos", "ref", "alt", "K562_ref", "HepG2_ref", "SKNSH_ref", "K562_alt", "HepG2_alt", "SKNSH_alt", "K562_skew", "HepG2_skew", "SKNSH_skew")

	gnomAD_chr_sums <- gnomAD_chr %>% 
		mutate(
			K562_abs_skew = abs(K562_skew), 
			HepG2_abs_skew = abs(HepG2_skew), 
			SKNSH_abs_skew = abs(SKNSH_skew), 
			mean_ref = (K562_ref + HepG2_ref + SKNSH_ref)/3, 
			mean_alt = (K562_alt + HepG2_alt + SKNSH_alt)/3, 
			mean_skew = (K562_skew + HepG2_skew + SKNSH_skew)/3, 
			mean_abs_skew = (K562_abs_skew + HepG2_abs_skew + SKNSH_abs_skew)/3, 
			count = 1) %>% 
		dplyr::select(-chr, -pos, -ref, -alt) %>% 
		colSums()

	gnomAD_chr_list[[i]] <- gnomAD_chr_sums

	print(gnomAD_chr_list)
}

gnomAD_sums <- gnomAD_chr_list %>% 
	bind_rows() %>% 
	colSums()

temp <- length(gnomAD_sums)
gnomAD_means <- (gnomAD_sums[1:(temp-1)]/gnomAD_sums[temp]) %>% 
	t() %>% as_tibble()

print(gnomAD_means)

write_tsv(gnomAD_means, "../../results/gnomAD_selection_analysis/gnomAD_mean_pred_genome_wide.txt")
