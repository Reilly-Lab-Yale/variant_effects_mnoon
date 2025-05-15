#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 8:00:00
#SBATCH -c 4
#SBATCH --mem=4G
#SBATCH --array 0-2
set -euo pipefail
module load miniconda
conda activate mcn_varef

# CONFIG
input_root="/vast/palmer/pi/reilly/VariantEffects/data/ucsc/combined_bed"
output_dir="/vast/palmer/pi/reilly/VariantEffects/data/ucsc/combined_bigwig"
cell_types=("HepG2" "K562" "SKNSH")

mkdir -p "$output_dir"

cell=${cell_types[$SLURM_ARRAY_TASK_ID]}

outfile="${output_dir}/${cell}.bw"

echo "[+] Processing $cell..."

# convert
bedGraphToBigWig ${input_root}/${cell}.bedGraph hg38.chrom.sizes ${outfile}

