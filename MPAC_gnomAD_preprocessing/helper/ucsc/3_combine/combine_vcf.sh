#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 8:00:00
#SBATCH -c 4
#SBATCH --mem=4G
set -euo pipefail
module load BCFtools/1.21-GCC-12.2.0

# CONFIG
input_root="/vast/palmer/pi/reilly/VariantEffects/data/ucsc/sorted"
output_dir="/vast/palmer/pi/reilly/VariantEffects/data/ucsc/combined"
cell_types=("HepG2" "K562" "SKNSH")

mkdir -p "$output_dir"

for cell in "${cell_types[@]}"; do
    indir="${input_root}/${cell}"
    outfile="${output_dir}/${cell}.bcf"

    echo "[+] Processing $cell..."

    # Natural sort and list BCFs
    files=$(ls "${indir}"/chr*.vcf.gz | sort -V)  # -V = natural sort (handles chr10 correctly)

    # Concatenate and write output
    bcftools concat -Ob -o "$outfile" $files

    # Index the result
    bcftools index -f "$outfile"

done
