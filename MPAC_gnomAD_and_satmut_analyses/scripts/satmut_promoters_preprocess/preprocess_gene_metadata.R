#!/bin/R

# Get gene level constraint metrics and other annotations

# load libraries
library(tidyverse)
library(data.table)
# library(genekitr)

# load gene names
gencode_gene_names <- as_tibble(rtracklayer::import("../../data/gencode_filtered_regions/gencode.v44.protein.coding.canonical.autosomes.0.based.bed", extraCols = c(id = "character"))) %>% 
	separate(id, sep="_", into=c("ensembl_gene", "ensembl_tx", "gene_name"), remove=F) %>% 
	mutate(ensembl_gene = gsub("\\..*", "", ensembl_gene)) %>% 
	mutate(ensembl_tx = gsub("\\..*", "", ensembl_tx)) %>% 
	dplyr::select(-name, -score)


# load LOEUF scores
# 	filter by mane_select and has loeuf score, then join by ensembl transcript id
loeuf <- as_tibble(fread("../../data/gene_constraint_metrics/loeuf/gnomad.v4.0.constraint_metrics.tsv.gz"))
loeuf <- distinct(filter(loeuf, mane_select)[c("transcript", "lof.oe_ci.upper")])
names(loeuf) <- c("ensembl_tx", "loeuf")


# load MOEUF scores
# 	filter by mane_select and has moeuf score, then join by ensembl transcript id
moeuf <- as_tibble(fread("../../data/gene_constraint_metrics/loeuf/gnomad.v4.0.constraint_metrics.tsv.gz"))
moeuf <- distinct(filter(moeuf, mane_select)[c("transcript", "mis.oe_ci.upper")])
names(moeuf) <- c("ensembl_tx", "moeuf")


# load s_het scores
# 	join by ensembl gene id
s_het <- as_tibble(fread("../../data/gene_constraint_metrics/s_het/media-1.tsv.gz"))
s_het <- distinct(s_het[c("ensg", "post_mean")])
names(s_het) <- c("ensembl_gene", "s_het")


# load AlphaMissense
alphmis <- as_tibble(fread("../../data/gene_constraint_metrics/alpha_missense/Supplementary_Table_S4.txt.gz"))
alphmis <- distinct(alphmis[c("gene", "mean_am_pathogenicity")])
names(alphmis) <- c("gene_name", "alphmis")
# use gene name instead of ensembl tx
# produces more overall matches


# Gene Expression
# 	translate from RefSeqId to Gene Symbol
# gene_expression <- as_tibble(fread("../../data/gene_expression_catalogs/rna_celline.tsv.gz"))
gene_expression <- as_tibble(fread("../../data/gene_expression_catalogs/rna_celline_filtered.tsv.gz"))
gene_expression <- gene_expression %>% 
	# filter(`Cell line` %in% c("K-562", "Hep-G2", "SK-N-SH")) %>% 
	mutate(`Cell line` = c("K-562" = "K562", "Hep-G2" = "HepG2", "SK-N-SH" = "SKNSH")[`Cell line`])

gene_expression <- gene_expression %>% 
	pivot_wider(names_from = `Cell line`, values_from = c(TPM, pTPM, nTPM))

gene_expression <- gene_expression %>% 
	dplyr::select(Gene, TPM_K562, TPM_HepG2, TPM_SKNSH) %>% 
	dplyr::rename(ensembl_gene = Gene) %>% 
	rowwise() %>% 
	mutate(
		logTPM_K562 = log2(TPM_K562+1), 
		logTPM_HepG2 = log2(TPM_HepG2+1), 
		logTPM_SKNSH = log2(TPM_SKNSH+1), 
		logTPM_max = pmax(logTPM_K562, logTPM_HepG2, logTPM_SKNSH)
	) %>% 
	ungroup()

# collate and save
satmut_promoters_gene_metadata <- gencode_gene_names %>% 
	left_join(loeuf) %>% 
	mutate(loeuf_bin = as.numeric(cut(loeuf, breaks = c(-Inf, quantile(loeuf, c(1:9)/10, na.rm=T), Inf)))) %>% 
	left_join(moeuf) %>% 
	mutate(moeuf_bin = as.numeric(cut(moeuf, breaks = c(-Inf, quantile(moeuf, c(1:9)/10, na.rm=T), Inf)))) %>% 
	left_join(s_het) %>% 
	mutate(s_het_bin = as.numeric(cut(s_het, breaks = c(-Inf, quantile(s_het, c(1:9)/10, na.rm=T), Inf)))) %>% 
	left_join(alphmis) %>% 
	mutate(alphmis_bin = as.numeric(cut(alphmis, breaks = c(-Inf, quantile(alphmis, c(1:9)/10, na.rm=T), Inf)))) %>% 
	left_join(gene_expression) %>% 
	mutate(TPM_K562_bin = as.numeric(cut(TPM_K562, breaks = c(-Inf, 1, 10, 100, 1000, Inf), na.rm=T))) %>% 
	mutate(TPM_HepG2_bin = as.numeric(cut(TPM_HepG2, breaks = c(-Inf, 1, 10, 100, 1000, Inf), na.rm=T))) %>% 
	mutate(TPM_SKNSH_bin = as.numeric(cut(TPM_SKNSH, breaks = c(-Inf, 1, 10, 100, 1000, Inf), na.rm=T)))

colSums(is.na(satmut_promoters_gene_metadata))

write_tsv(satmut_promoters_gene_metadata, gzfile("../../results/satmut_promoters_preprocess/satmut_promoters_gene_metadata/satmut_promoters_gene_metadata.txt.gz"))

# filter for supplement
satmut_promoters_gene_metadata <- as_tibble(fread("../../results/satmut_promoters_preprocess/satmut_promoters_gene_metadata/satmut_promoters_gene_metadata.txt.gz"))

satmut_promoters_gene_metadata_supp <- satmut_promoters_gene_metadata %>% 
	dplyr::select(seqnames, start, end, width, strand, id, ensembl_gene, ensembl_tx, gene_name, loeuf, loeuf_bin, moeuf, moeuf_bin, s_het, s_het_bin, alphmis, alphmis_bin, TPM_K562, TPM_HepG2, TPM_SKNSH, logTPM_K562, logTPM_HepG2, logTPM_SKNSH)
	
write_tsv(satmut_promoters_gene_metadata_supp, gzfile("../../results/satmut_promoters_preprocess/satmut_promoters_gene_metadata/satmut_promoters_gene_metadata_supp.txt.gz"))
