#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 3:00:00
#SBATCH -c 4
#SBATCH --mem-per-cpu=5G
#SBATCH --array 0-2

module load BCFtools


root="/vast/palmer/pi/reilly/VariantEffects/data/ucsc"



cell_types=(K562 HepG2 SKNSH)
cell_type=${cell_types[$SLURM_ARRAY_TASK_ID]}

bcftools view ${root}/combined/${cell_type}.bcf -Oz > ${root}/vcf/${cell_type}.vcf.gz
tabix -p vcf ${root}/vcf/${cell_type}.vcf.gz
