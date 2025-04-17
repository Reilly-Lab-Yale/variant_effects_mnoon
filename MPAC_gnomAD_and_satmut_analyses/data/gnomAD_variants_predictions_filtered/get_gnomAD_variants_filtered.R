#!/usr/bin/env R

library(tidyverse)
library(data.table)

# Get chromosome number from command line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Please provide a chromosome number (1-22) as an argument.")
}

chr_number <- as.numeric(args[1])
if (is.na(chr_number) || chr_number < 1 || chr_number > 22) {
  stop("Invalid chromosome number. Please provide a number between 1 and 22.")
}

# Define file paths dynamically
gnomAD_variants_file <- sprintf("../gnomAD_variants_predictions/gnomad.genomes.v3.1.2.sites.chr%d.vcf.gz", chr_number)
gnomAD_variants_bed_file <- sprintf("../gnomAD_variants_predictions_bed/chr%d.tsv.gz", chr_number)
gnomAD_variants_filtered_file <- sprintf("../gnomAD_variants_predictions_filtered/gnomad.genomes.v3.1.2.sites.chr%d.filtered.vcf.gz", chr_number)

# Read data
gnomAD_variants <- fread(gnomAD_variants_file)
gnomAD_variants_bed <- fread(gnomAD_variants_bed_file, header = FALSE)[, c(1, 3, 4, 5)]
names(gnomAD_variants_bed) <- c("chrom", "pos", "ref", "alt")

# Filter and save
gnomAD_variants_filtered <- gnomAD_variants %>% right_join(gnomAD_variants_bed)
write_tsv(gnomAD_variants_filtered, gzfile(gnomAD_variants_filtered_file))
