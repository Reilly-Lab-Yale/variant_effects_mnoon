#!/bin/bash
#SBATCH -J convertMalinois
#SBATCH -N 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH -t 24:00:00
#SBATCH --mail-user stephen.rong@yale.edu
#SBATCH --mail-type ALL
#SBATCH -a 1-22

i="${SLURM_ARRAY_TASK_ID}"

bash convert_Malinois_gnomAD_v3.1.2_precomputed.sh gnomad.genomes.v3.1.2.sites.chr${i}.vcf.gz gnomad.genomes.v3.1.2.sites.chr${i}.converted.vcf.gz
