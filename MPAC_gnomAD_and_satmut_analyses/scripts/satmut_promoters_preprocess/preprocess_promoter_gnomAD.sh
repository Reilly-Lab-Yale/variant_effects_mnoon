#!/bin/bash
#SBATCH -J extractPromoterGnomAD
#SBATCH -N 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH -t 24:00:00
#SBATCH --mail-user stephen.rong@yale.edu
#SBATCH --mail-type ALL
#SBATCH -a 1-22

i="${SLURM_ARRAY_TASK_ID}"

input_dir="../../data/gnomAD_genomes_v3/"
regions_dir="../../results/satmut_promoters_preprocess/satmut_promoters_regions/"
output_dir="../../results/satmut_promoters_preprocess/satmut_promoters_gnomAD/"

tabix -h ${input_dir}gnomad.genomes.v3.1.2.sites.chr${i}.subinfo.vcf.gz -R ${regions_dir}satmut_promoters_promoter_regions_chr${i}.bed | bgzip >| ${output_dir}gnomad.genomes.v3.1.2.sites.chr${i}.subinfo.promoter.temp.vcf.gz
bcftools sort ${output_dir}gnomad.genomes.v3.1.2.sites.chr${i}.subinfo.promoter.temp.vcf.gz | bgzip >| ${output_dir}gnomad.genomes.v3.1.2.sites.chr${i}.subinfo.promoter.vcf.gz
tabix -p vcf ${output_dir}gnomad.genomes.v3.1.2.sites.chr${i}.subinfo.promoter.vcf.gz
rm ${output_dir}gnomad.genomes.v3.1.2.sites.chr${i}.subinfo.promoter.temp.vcf.gz
