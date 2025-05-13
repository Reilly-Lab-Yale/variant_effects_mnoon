#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 8:00:00
#SBATCH -c 4
#SBATCH --mem=16G
set -euo pipefail
module load miniconda
conda activate mcn_varef

# CONFIG
input_root="/vast/palmer/pi/reilly/VariantEffects/data/ucsc/bed"
output_dir="/vast/palmer/pi/reilly/VariantEffects/data/ucsc/combined_bed"
chrom_sizes="hg38.chrom.sizes"  # UCSC chrom sizes file
cell_types=("HepG2" "K562" "SKNSH")

mkdir -p "$output_dir"

for cell in "${cell_types[@]}"; do
    indir="${input_root}/${cell}"
    merged_bedgraph="${output_dir}/${cell}.bedGraph"
    final_gz="${output_dir}/${cell}.bedGraph.gz"

    echo "[+] Processing $cell..."

    # Gather and sort all bedGraph files naturally, then concatenate and sort the contents
    files=$(ls "${indir}"/chr*.bedgraph | sort -V)

    # Concatenate, then compress. assuming individual files already sorted.
    #cat $files  > "$merged_bedgraph"
    #bgzip "$merged_bedgraph"
	#tabix index
	tabix -p bed ${merged_bedgraph}.gz

done
