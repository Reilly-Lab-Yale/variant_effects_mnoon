#!/bin/R

# load libraries
library(tidyverse)
library(data.table)

# load bioconductor
library(rtracklayer)
library(plyranges)


# helper functions
extend_granges <- function(x, upstream=0, downstream=0) {
	# based on https://support.bioconductor.org/p/78652/
	if (any(strand(x) == "*")) {
		warning("'*' ranges were treated as '+'")
	}
	on_plus <- strand(x) == "+" | strand(x) == "*"
	new_start <- start(x) - ifelse(on_plus, upstream, downstream)
	new_end <- end(x) + ifelse(on_plus, downstream, upstream)
	ranges(x) <- IRanges(new_start, new_end)
	return(trim(x))
}


# load gencode gff3
gff_full <- rtracklayer::import("gencode.v44.basic.annotation.gff3.gz")

# # filter only protein coding genes on autosomes, old john version
# gff_protein_coding_genes <- gff_full %>%
# 	filter(type == "gene") %>% 
# 	filter(gene_type == "protein_coding") %>% 
# 	filter(seqnames %in% paste0("chr", 1:22)) %>% 
# 	filter(!is.na(hgnc_id)) %>% 
# 	filter(!(any(tag == "readthrough_gene")))

# filter only protein coding genes on autosomes, new john version
gff_protein_coding_genes <- gff_full %>%
	filter(type == "transcript") %>% 
	filter(transcript_type == "protein_coding") %>% 
	as_tibble() %>% filter(grepl("Ensembl_canonical", tag)) %>% GRanges() %>% 
	filter(seqnames %in% paste0("chr", 1:22))

# convert to bed file
gff_protein_coding_genes_bed <- gff_protein_coding_genes %>% 
	mutate(name = gene_name) %>% 
	dplyr::select(name)

# filter only protein coding exons on autosomes
gff_protein_coding_exons <- gff_full %>%
	filter(type == "exon") %>% 
	filter(gene_type == "protein_coding") %>% 
	filter(seqnames %in% paste0("chr", 1:22))

# filter genes with hgnc_id and remove readthrough_genes
gff_protein_coding_exons <- gff_protein_coding_exons %>% 
	filter(!is.na(hgnc_id)) %>% 
	filter(!(any(tag == "readthrough_gene")))

# convert to bed file
gff_protein_coding_exons_bed <- gff_protein_coding_exons %>% 
	mutate(name = gene_name) %>% 
	dplyr::select(name)

# filter only all exons on autosomes
gff_all_exons <- gff_full %>%
	filter(type == "exon") %>% 
	filter(seqnames %in% paste0("chr", 1:22))

# convert to bed file
gff_all_exons_bed <- gff_all_exons %>% 
	mutate(name = gene_name) %>% 
	dplyr::select(name)

# save
rtracklayer::export(gff_protein_coding_genes_bed, "gencode.v44.protein.coding.genes.autosomes.v2.bed")
rtracklayer::export(gff_protein_coding_exons_bed, "gencode.v44.protein.coding.exons.autosomes.v2.bed")
rtracklayer::export(gff_all_exons_bed, "gencode.v44.basic.annotation.exons.autosomes.v2.bed")


# get promoters
gff_protein_coding_tss <- gff_protein_coding_genes %>% 
	extend_granges(downstream = -width(gff_protein_coding_genes))
gff_protein_coding_promoters_1kb <- gff_protein_coding_tss %>% 
	extend_granges(upstream = 1000)
gff_protein_coding_promoters_750bp <- gff_protein_coding_tss %>% 
	extend_granges(upstream = 750)
gff_protein_coding_promoters_500bp <- gff_protein_coding_tss %>% 
	extend_granges(upstream = 500)
gff_protein_coding_promoters_250bp <- gff_protein_coding_tss %>% 
	extend_granges(upstream = 250)

# convert to bed file
gff_protein_coding_tss_bed <- gff_protein_coding_tss %>% 
	mutate(name = gene_name) %>% 
	dplyr::select(name)
gff_protein_coding_promoters_1kb_bed <- gff_protein_coding_promoters_1kb %>% 
	mutate(name = gene_name) %>% 
	dplyr::select(name)
gff_protein_coding_promoters_750bp_bed <- gff_protein_coding_promoters_750bp %>% 
	mutate(name = gene_name) %>% 
	dplyr::select(name)
gff_protein_coding_promoters_500bp_bed <- gff_protein_coding_promoters_500bp %>% 
	mutate(name = gene_name) %>% 
	dplyr::select(name)
gff_protein_coding_promoters_250bp_bed <- gff_protein_coding_promoters_250bp %>% 
	mutate(name = gene_name) %>% 
	dplyr::select(name)

# save
rtracklayer::export(gff_protein_coding_tss_bed, "gencode.v44.protein.coding.tss.autosomes.v2.bed")
rtracklayer::export(gff_protein_coding_promoters_1kb_bed, "gencode.v44.protein.coding.1kb.promoters.autosomes.v2.bed")
rtracklayer::export(gff_protein_coding_promoters_750bp_bed, "gencode.v44.protein.coding.750bp.promoters.autosomes.v2.bed")
rtracklayer::export(gff_protein_coding_promoters_500bp_bed, "gencode.v44.protein.coding.500bp.promoters.autosomes.v2.bed")
rtracklayer::export(gff_protein_coding_promoters_250bp_bed, "gencode.v44.protein.coding.250bp.promoters.autosomes.v2.bed")


# identify first, internal, last exons
gff_protein_coding_exons_splice <- gff_protein_coding_exons %>% 
	as_tibble() %>% 
	group_by(transcript_name) %>%  # more robust than gene_name
	mutate(first = ((exon_number == 1) & (max(exon_number) > 1))) %>% 
	mutate(internal = !(exon_number %in% c(1, max(exon_number)))) %>% 
	mutate(last = ((exon_number == max(exon_number)) & (max(exon_number) > 1))) %>% 
	ungroup()

# extend exons to splice regions
# 	these are based on maxentscan
acceptor <- 20
donor <- 6
gff_protein_coding_exons_splice <- gff_protein_coding_exons_splice %>% 
	mutate(start = start - ifelse(strand == "+", 0, donor)*first, end = end + ifelse(strand == "+", donor, 0)*first) %>% 
	mutate(start = start - ifelse(strand == "+", acceptor, donor)*internal, end = end + ifelse(strand == "+", donor, acceptor)*internal) %>% 
	mutate(start = start - ifelse(strand == "+", acceptor, 0)*last, end = end + ifelse(strand == "+", 0, acceptor)*last) %>% 
	GRanges()

# save
gff_protein_coding_exons_splice_bed <- gff_protein_coding_exons_splice %>% 
	mutate(name = gene_name) %>% 
	dplyr::select(name)
rtracklayer::export(gff_protein_coding_exons_splice_bed, "gencode.v44.protein.coding.exons.splice.autosomes.v2.bed")


# identify first, internal, last exons
gff_all_exons_splice <- gff_all_exons %>% 
	as_tibble() %>% 
	group_by(transcript_name) %>%  # more robust than gene_name
	mutate(first = ((exon_number == 1) & (max(exon_number) > 1))) %>% 
	mutate(internal = !(exon_number %in% c(1, max(exon_number)))) %>% 
	mutate(last = ((exon_number == max(exon_number)) & (max(exon_number) > 1))) %>% 
	ungroup()

# extend exons to splice regions
# 	these are based on maxentscan
acceptor <- 20
donor <- 6
gff_all_exons_splice <- gff_all_exons_splice %>% 
	mutate(start = start - ifelse(strand == "+", 0, donor)*first, end = end + ifelse(strand == "+", donor, 0)*first) %>% 
	mutate(start = start - ifelse(strand == "+", acceptor, donor)*internal, end = end + ifelse(strand == "+", donor, acceptor)*internal) %>% 
	mutate(start = start - ifelse(strand == "+", acceptor, 0)*last, end = end + ifelse(strand == "+", 0, acceptor)*last) %>% 
	GRanges()

# save
gff_all_exons_splice_bed <- gff_all_exons_splice %>% 
	mutate(name = gene_name) %>% 
	dplyr::select(name)
rtracklayer::export(gff_all_exons_splice_bed, "gencode.v44.basic.annotation.exons.splice.autosomes.v2.bed")
