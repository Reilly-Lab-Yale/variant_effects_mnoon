#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 4:00:00
#SBATCH -J extract_vars

zcat /home/mcn26/varef/scripts/noon_data/0.merge/combined.chr1.vcf.gz | grep "synonymous_variant" > /gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/grabbed/syn.tsv

zcat /home/mcn26/varef/scripts/noon_data/0.merge/combined.chr1.vcf.gz | grep "missense_variant" > /gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/grabbed/mis.tsv
