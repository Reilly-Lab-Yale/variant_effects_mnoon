#!/bin/bash
#SBATCH -J extractPromoterCADD
#SBATCH -N 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH -t 24:00:00
#SBATCH --mail-user stephen.rong@yale.edu
#SBATCH --mail-type ALL
#SBATCH -a 1-22

i="${SLURM_ARRAY_TASK_ID}"

# cluster - temp
input_file="https://krishna.gs.washington.edu/download/CADD/v1.7/GRCh38/whole_genome_SNVs_inclAnno.tsv.gz"
regions_dir="../../results/satmut_promoters_preprocess/satmut_promoters_regions/"
output_dir="../../results/satmut_promoters_preprocess/satmut_promoters_CADD/"

tabix -h ${input_file} -R ${regions_dir}satmut_promoters_promoter_regions_${i}.bed | tail -n +2 | awk -F'\t' '{print $1, $2, $3, $4, $5, $6, $7, $8, $11, $12, $19, $20, $21, $22, $23, $24, $133, $134, $135, $137, $138, $145, $146, $147, $148, $150, $153}' | bgzip >| ${output_dir}whole_genome_SNVs_inclAnno.${i}.subinfo.promoter.txt.gz
