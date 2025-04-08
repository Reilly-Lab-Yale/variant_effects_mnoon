#!/bin/bash
#SBATCH -J subinfo_gnomAD
#SBATCH -N 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH -t 24:00:00
#SBATCH --mail-user stephen.rong@yale.edu
#SBATCH --mail-type ALL
#SBATCH -a 1-22

i="${SLURM_ARRAY_TASK_ID}"

gnomAD="./"

# old
# bcftools annotate -x ^INFO/AF,^INFO/AC,^INFO/AN,^INFO/AF_oth,^INFO/AC_oth,^INFO/AN_oth,^INFO/AF_ami,^INFO/AC_ami,^INFO/AN_ami,^INFO/AF_sas,^INFO/AC_sas,^INFO/AN_sas,^INFO/AF_fin,^INFO/AC_fin,^INFO/AN_fin,^INFO/AF_eas,^INFO/AC_eas,^INFO/AN_eas,^INFO/AF_amr,^INFO/AC_amr,^INFO/AN_amr,^INFO/AF_afr,^INFO/AC_afr,^INFO/AN_afr,^INFO/AF_mid,^INFO/AC_mid,^INFO/AN_mid,^INFO/AF_asj,^INFO/AC_asj,^INFO/AN_asj,^INFO/AF_nfe,^INFO/AC_nfe,^INFO/AN_nfe,^INFO/AF_popmax,^INFO/AC_popmax,^INFO/AN_popmax,^INFO/cadd_raw_score,^INFO/cadd_phred,^INFO/revel_score,^INFO/splice_ai_max_ds,^INFO/splice_ai_consequence,^INFO/primate_ai_score,^INFO/vep ${gnomAD}gnomad.genomes.v3.1.2.sites.chr${i}.vcf.bgz -O b -o gnomad.genomes.v3.1.2.sites.chr${i}.subinfo.vcf.bgz
# tabix -p vcf gnomad.genomes.v3.1.2.sites.chr${i}.subinfo.vcf.bgz

# new
bcftools annotate -x ^INFO/AF,^INFO/AC,^INFO/AN,^INFO/AF_oth,^INFO/AC_oth,^INFO/AN_oth,^INFO/AF_ami,^INFO/AC_ami,^INFO/AN_ami,^INFO/AF_sas,^INFO/AC_sas,^INFO/AN_sas,^INFO/AF_fin,^INFO/AC_fin,^INFO/AN_fin,^INFO/AF_eas,^INFO/AC_eas,^INFO/AN_eas,^INFO/AF_amr,^INFO/AC_amr,^INFO/AN_amr,^INFO/AF_afr,^INFO/AC_afr,^INFO/AN_afr,^INFO/AF_mid,^INFO/AC_mid,^INFO/AN_mid,^INFO/AF_asj,^INFO/AC_asj,^INFO/AN_asj,^INFO/AF_nfe,^INFO/AC_nfe,^INFO/AN_nfe,^INFO/AF_popmax,^INFO/AC_popmax,^INFO/AN_popmax,^INFO/cadd_raw_score,^INFO/cadd_phred,^INFO/revel_score,^INFO/splice_ai_max_ds,^INFO/splice_ai_consequence,^INFO/primate_ai_score,^INFO/vep ${gnomAD}gnomad.genomes.v3.1.2.sites.chr${i}.vcf.bgz -O v -o gnomad.genomes.v3.1.2.sites.chr${i}.subinfo.vcf
bgzip gnomad.genomes.v3.1.2.sites.chr${i}.subinfo.vcf
tabix -p vcf gnomad.genomes.v3.1.2.sites.chr${i}.subinfo.vcf.gz
