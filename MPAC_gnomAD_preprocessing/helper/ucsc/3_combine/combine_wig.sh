#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 8:00:00
#SBATCH -c 4
#SBATCH --mem=128G
set -euo pipefail
module load miniconda
conda activate mcn_varef

# CONFIG
input_root="/vast/palmer/pi/reilly/VariantEffects/data/ucsc/bw"
output_dir="/vast/palmer/pi/reilly/VariantEffects/data/ucsc/combined_bw"
chrom_sizes="hg38.chrom.sizes"  # UCSC chrom sizes file
cell_types=("HepG2" "K562" "SKNSH")

mkdir -p "$output_dir"

for cell in "${cell_types[@]}"; do
    indir="${input_root}/${cell}"
    merged_wig="${output_dir}/${cell}.wig"
    final_bw="${output_dir}/${cell}.bw"

    echo "[+] Processing $cell..."

    # Natural sort of BigWig files
    files=$(ls "${indir}"/chr*.bw | sort -V)

    # Merge into .wig format
    bigWigMerge $files "$merged_wig"

    # Convert to final .bw
    wigToBigWig "$merged_wig" "$chrom_sizes" "$final_bw"

done
