#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 8:00:00
#SBATCH -c 4
#SBATCH --mem=4G
#SBATCH --array 0-2
set -euo pipefail
module load BCFtools/1.21-GCC-12.2.0

# CONFIG
input_root="/vast/palmer/pi/reilly/VariantEffects/data/ucsc/broken"
output_dir="/vast/palmer/pi/reilly/VariantEffects/data/ucsc/combined_vcf"
cell_types=("HepG2" "K562" "SKNSH")

mkdir -p "$output_dir"

cell=${cell_types[$SLURM_ARRAY_TASK_ID]}

indir="${input_root}/${cell}"
outfile="${output_dir}/${cell}.vcf.gz"

echo "[+] Processing $cell..."

# Natural sort and list VCFs
files=$(ls "${indir}"/chr*.vcf | sort -V)  # -V = natural sort (e.g. handles chr10 vs chr1 correctly)

# Concatenate and write output
bcftools concat -Ob -o "$outfile" $files

# Index the result
bcftools index -t "$outfile"
