#!/bin/bash
#SBATCH --job-name=gnomAD_chromosomes
#SBATCH --output=logs/gnomAD_chr_%A_%a.out
#SBATCH --error=logs/gnomAD_chr_%A_%a.err
#SBATCH --array=1-22
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=2

# Run the R script with the chromosome number from the job array
Rscript get_gnomAD_variants_filtered.R $SLURM_ARRAY_TASK_ID
gunzip gnomad.genomes.v3.1.2.sites.chr${SLURM_ARRAY_TASK_ID}.filtered.vcf.gz
bgzip gnomad.genomes.v3.1.2.sites.chr${SLURM_ARRAY_TASK_ID}.filtered.vcf
tabix -f -s1 -b2 -e2 -S1 gnomad.genomes.v3.1.2.sites.chr${SLURM_ARRAY_TASK_ID}.filtered.vcf.gz
