#!/bin/R

# Take VEP tables, remap factors, collapse along dimensions, and perform statistical tests

# load libraries
library(tidyverse)
library(data.table)
library(wrapr)

# load tables
gnomAD_vep_table <- as_tibble(fread("../../data/gnomAD_mackenzie_processed/ensembl_vep_v4/part-00000-20511296-fdd1-4cb2-9ec8-175d5392190b-c000.csv.gz"))

# remap and collapse bins
category_short_map <- c(
	`SINGLETON` = "RARE",
	`ULTRARARE` = "RARE",
	`RARE` = "RARE",
	`LOW_FREQ` = "COMMON",
	`COMMON` = "COMMON"
)

worst_consq_string_map <- c(
	`splice_acceptor_variant` = "splice acceptor variant",
	`splice_donor_variant` = "splice donor variant",
	`stop_gained` = "stop gained",
	`stop_lost` = "stop lost",
	`start_lost` = "start lost",
	`missense_variant` = "missense variant",
	`splice_region_variant` = "splice region variant",
	`incomplete_terminal_codon_variant` = "incomplete terminal codon variant",
	`synonymous_variant` = "synonymous variant",
	`stop_retained_variant` = "stop retained variant",
	`coding_sequence_variant` = "coding sequence variant",
	`mature_miRNA_variant` = "mature miRNA variant",
	`5_prime_UTR_variant` = "5 prime UTR variant",
	`3_prime_UTR_variant` = "3 prime UTR variant",
	`non_coding_transcript_exon_variant` = "non coding transcript exon variant",
	`intron_variant` = "intron variant",
	`non_coding_transcript_variant` = "non coding transcript variant",
	`upstream_gene_variant` = "upstream gene variant",
	`downstream_gene_variant` = "downstream gene variant",
	`TF_binding_site_variant` = "TF binding site variant",
	`regulatory_region_variant` = "regulatory region variant",
	`intergenic_variant` = "intergenic variant"
)

# preprocessing factors
gnomAD_vep_table <- gnomAD_vep_table %>% 
	mutate(category = factor(category, levels = names(category_short_map))) %>% 
	mutate(worst_consq_string = factor(worst_consq_string_map[worst_consq_string], levels = rev(unique(worst_consq_string_map))))

# get odds ratios
odds_helper <- function(gnomAD_main_table, cond_list=c(""), min_qc=50) {
	# gnomAD_main_table is always gnomAD_main_table from above
	# prefix is one of "mean", "K562", "HepG2", or "SKNSH"
	# cond_list is a c(), defaults to empty, could contain in_TF, in_rep, or emVar_category, or any combination
	# min_qc = minimum number of observations in bin to calculate statistics

	# collapse needed bins
	gnomAD_main_table_temp <- gnomAD_main_table %>% 
		dplyr::select(!!!sapply(cond_list, sym), count, category)

	# get category counts
	gnomAD_main_table_temp_p <- gnomAD_main_table_temp %>% 
		group_by(!!!sapply(cond_list, sym), category) %>% 
		summarise(
			count = sum(count)
		) %>% 
		mutate(category = factor(category, levels = names(category_short_map))) %>% arrange(category) %>% 
		pivot_wider(names_from = category, values_from = count, names_prefix = "long_") %>% 
		ungroup()

	# collapse counts in remapped bins
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		mutate(category = factor(category_short_map[category], levels = unique(category_short_map))) %>% arrange(category) %>% 
		group_by(!!!sapply(cond_list, sym), category) %>% 
		summarise(
			count = sum(count)
		) %>% 
		ungroup()

	# pivot wider rare and common counts
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>%
		arrange(!!!sapply(cond_list, sym), category) %>% 
		pivot_wider(names_from = category, values_from = count, names_prefix = "short_") %>% 
		mutate_at(c("short_RARE", "short_COMMON"), function(x) {ifelse(is.na(x), 0, x)}) %>% 
		mutate(count = short_RARE + short_COMMON) %>% 
		dplyr::select(!!!sapply(cond_list, sym), count, short_RARE, short_COMMON)

	# get genome baseline
	gnomAD_main_table_temp_gw <- colSums(gnomAD_main_table_temp[c("short_RARE", "short_COMMON")])

	# just reorganize odds
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>%
		arrange(!!!sapply(cond_list, sym))

	# compute fet
	# print(paste(prefix, cond_list, min_qc))
	wrapr::let(c(VAR1 = paste0("fet_RARE_COMMON"), VAR2 = paste0("fet_RARE_COMMON_pval"), VAR3 = paste0("fet_RARE_COMMON_odds"), VAR4 = paste0("fet_RARE_COMMON_lci"), VAR5 = paste0("fet_RARE_COMMON_uci"), VAR6 = paste0("fet_RARE_COMMON_padj"), VAR7 = paste0("fet_RARE_COMMON_sig")), 
		gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
			# filter(short_RARE + short_COMMON >= 50) %>% 
			rowwise() %>% 
			mutate(VAR1 = ifelse(short_RARE + short_COMMON >= min_qc, list(fisher.test(matrix(c(short_RARE+1, short_COMMON+1, gnomAD_main_table_temp_gw[["short_RARE"]]-short_RARE+1, gnomAD_main_table_temp_gw[["short_COMMON"]]-short_COMMON+1), nrow=2))), NA)) %>% 
			mutate(VAR2 = ifelse(short_RARE + short_COMMON >= min_qc, VAR1$p.val, NA)) %>% 
			mutate(VAR3 = ifelse(short_RARE + short_COMMON >= min_qc, VAR1$estimate, NA)) %>% 
			mutate(VAR4 = ifelse(short_RARE + short_COMMON >= min_qc, VAR1$conf.int[1], NA)) %>% 
			mutate(VAR5 = ifelse(short_RARE + short_COMMON >= min_qc, VAR1$conf.int[2], NA)) %>% 
			ungroup() %>% 
			mutate(VAR6 = p.adjust(VAR2, method = "fdr")) %>% 
			mutate(VAR7 = ifelse(VAR6 < 0.05, "*", ""))
	)

	# join category props
	#	no min_qc, no CIs
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		full_join(gnomAD_main_table_temp_p) %>% 
		mutate(across(starts_with("long_"), 
			~ . / count, 
			.names = "long_prop_{sub('long_', '', .col)}")) %>% 
		mutate(across(starts_with("short_"), 
			~ . / count, 
			.names = "short_prop_{sub('short_', '', .col)}"))

	return(gnomAD_main_table_temp)
}

gnomAD_vep_table_odds <- gnomAD_vep_table %>%
	odds_helper(c("worst_consq_string"))
gnomAD_vep_table_odds_category <- gnomAD_vep_table %>% 
	mutate(category_copy = category) %>% 
	odds_helper(c("category_copy", "worst_consq_string"))

# get phyloP ratios
phyloP_helper <- function(gnomAD_main_table, cond_list=c(""), min_qc=50) {
	# gnomAD_main_table is always gnomAD_main_table from above
	# prefix is one of "mean", "K562", "HepG2", or "SKNSH"
	# cond_list is a c(), defaults to empty, could contain in_TF, in_rep, or emVar_category, or any combination
	# min_qc = minimum number of observations in bin to calculate statistics

	# collapse needed bins
	gnomAD_main_table_temp <- gnomAD_main_table %>% 
		dplyr::select(!!!sapply(cond_list, sym), count, sum_phylop, sum_of_squared_phylop, phylop_significant)

	# collapse counts in remapped bins
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		group_by(!!!sapply(cond_list, sym)) %>% 
		summarise(
			sum_of_phylop_significant = sum(phylop_significant*count),
			sum_of_squared_phylop = sum(sum_of_squared_phylop), 
			sum_phylop = sum(sum_phylop),
			count = sum(count), 
		) %>% 
		ungroup() %>% 
		dplyr::select(!!!sapply(cond_list, sym), count, sum_phylop, sum_of_squared_phylop, sum_of_phylop_significant)

	# just reorganize phyloP
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>%
		arrange(!!!sapply(cond_list, sym))

	# compute phyloP statistics
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		mutate(phyloP_mean = ifelse(count >= min_qc, (sum_phylop/count), NA)) %>% 
		mutate(phyloP_sd = ifelse(count >= min_qc, (sqrt((sum_of_squared_phylop - count*phyloP_mean**2)/(count-1))), NA)) %>% 
		mutate(phyloP_se = ifelse(count >= min_qc, (phyloP_sd/sqrt(count)), NA)) %>% 
		mutate(phyloP_lci = ifelse(count >= min_qc, (phyloP_mean - 2*phyloP_se), NA)) %>% 
		mutate(phyloP_uci = ifelse(count >= min_qc, (phyloP_mean + 2*phyloP_se), NA)) %>% 
		mutate(phyloP_stat = ifelse(count >= min_qc, ((phyloP_mean - 0)/phyloP_se), NA)) %>% 
		rowwise() %>% 
		mutate(phyloP_pval = ifelse(count >= min_qc, (2*pt(-abs(phyloP_stat), count-1, lower.tail = TRUE)), NA)) %>% 
		ungroup() %>% 
		mutate(phyloP_padj = p.adjust(phyloP_pval, method = "fdr")) %>% 
		mutate(phyloP_sig = ifelse(phyloP_padj < 0.05, "*", "")) 

	# compute phyloP cons statistics
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		mutate(
			phyloP_cons_prop = ifelse(count >= min_qc, sum_of_phylop_significant/count, NA)
		) %>% 
		mutate(
			phyloP_cons_prop_sd = ifelse(count >= min_qc, sqrt(phyloP_cons_prop*(1-phyloP_cons_prop)/count), NA)
		) %>% 
		mutate(
			phyloP_cons_prop_lci = ifelse(count >= min_qc, phyloP_cons_prop - 2*phyloP_cons_prop_sd, NA),
			phyloP_cons_prop_uci = ifelse(count >= min_qc, phyloP_cons_prop + 2*phyloP_cons_prop_sd, NA)
		)

	return(gnomAD_main_table_temp)
}

gnomAD_vep_table_phyloP <- gnomAD_vep_table %>%
	phyloP_helper(c("worst_consq_string"))
gnomAD_vep_table_phyloP_category <- gnomAD_vep_table %>% 
	mutate(category_copy = category) %>% 
	phyloP_helper(c("category_copy", "worst_consq_string"))

# get mutrate ratios
mutrate_helper <- function(gnomAD_main_table, cond_list=c(""), min_qc=50) {
	# gnomAD_main_table is always gnomAD_main_table from above
	# prefix is one of "mean", "K562", "HepG2", or "SKNSH"
	# cond_list is a c(), defaults to empty, could contain in_TF, in_rep, or emVar_category, or any combination
	# min_qc = minimum number of observations in bin to calculate statistics

	# collapse needed bins
	gnomAD_main_table_temp <- gnomAD_main_table %>% 
		dplyr::select(!!!sapply(cond_list, sym), count, sum_roulette_MR, sum_of_squared_roulette_MR)

	# collapse counts in remapped bins
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		group_by(!!!sapply(cond_list, sym)) %>% 
		summarise(
			count = sum(count), 
			sum_roulette_MR = sum(sum_roulette_MR),
			sum_of_squared_roulette_MR = sum(sum_of_squared_roulette_MR)
		) %>% 
		ungroup()

	# just reorganize mutrate
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>%
		arrange(!!!sapply(cond_list, sym))

	# compute mutrate statistics
	gnomAD_main_table_temp <- gnomAD_main_table_temp %>% 
		mutate(mutrate_mean = ifelse(count >= min_qc, (sum_roulette_MR/count), NA)) %>% 
		mutate(mutrate_sd = ifelse(count >= min_qc, (sqrt((sum_of_squared_roulette_MR - count*mutrate_mean**2)/(count-1))), NA)) %>% 
		mutate(mutrate_se = ifelse(count >= min_qc, (mutrate_sd/sqrt(count)), NA)) %>% 
		mutate(mutrate_lci = ifelse(count >= min_qc, (mutrate_mean - 2*mutrate_se), NA)) %>% 
		mutate(mutrate_uci = ifelse(count >= min_qc, (mutrate_mean + 2*mutrate_se), NA)) %>% 
		mutate(mutrate_stat = ifelse(count >= min_qc, ((mutrate_mean - 0)/mutrate_se), NA)) %>% 
		rowwise() %>% 
		mutate(mutrate_pval = ifelse(count >= min_qc, (2*pt(-abs(mutrate_stat), count-1, lower.tail = TRUE)), NA)) %>% 
		ungroup() %>% 
		mutate(mutrate_padj = p.adjust(mutrate_pval, method = "fdr")) %>% 
		mutate(mutrate_sig = ifelse(mutrate_padj < 0.05, "*", "")) 

	return(gnomAD_main_table_temp)
}

gnomAD_vep_table_mutrate <- gnomAD_vep_table %>%
	mutrate_helper(c("worst_consq_string"))
gnomAD_vep_table_mutrate_category <- gnomAD_vep_table %>% 
	mutate(category_copy = category) %>% 
	mutrate_helper(c("category_copy", "worst_consq_string"))

# do full joins
gnomAD_vep_table_full <- gnomAD_vep_table_odds %>% full_join(gnomAD_vep_table_phyloP) %>% full_join(gnomAD_vep_table_mutrate)
gnomAD_vep_table_full_category <- gnomAD_vep_table_odds_category %>% full_join(gnomAD_vep_table_phyloP_category) %>% full_join(gnomAD_vep_table_mutrate_category)

# save table and rds
saveRDS(gnomAD_vep_table_full, "../../results/gnomAD_selection_preprocess/gnomAD_vep_table_full.rds")
write_tsv(gnomAD_vep_table_full, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_vep_table_full.tsv.gz"))
saveRDS(gnomAD_vep_table_full_category, "../../results/gnomAD_selection_preprocess/gnomAD_vep_table_full_category.rds")
write_tsv(gnomAD_vep_table_full_category, gzfile("../../results/gnomAD_selection_preprocess/gnomAD_vep_table_full_category.tsv.gz"))
