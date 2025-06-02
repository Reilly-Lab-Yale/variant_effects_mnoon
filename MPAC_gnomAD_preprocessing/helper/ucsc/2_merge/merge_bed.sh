#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 8:00:00
#SBATCH -c 4
#SBATCH --mem=16G


cd /home/mcn26/varef/data/ucsc/pre_bigbed_bed


cell_types=("HepG2" "K562" "SKNSH")


for cell in "${cell_types[@]}"; do
    echo "[+] Processing $cell..."
    # Gather and sort all bed files by chromosome, then concatenate and sort the contents
    files=$(find ${cell} -maxdepth 1 -mindepth 1 -exec echo {} \; | sort -V)
    #echo ${files}
    cat $files  > ${cell}.bed
    

done