#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 8:00:00
#SBATCH -c 4
#SBATCH --mem=120G
#SBATCH --array=0-2

cell_types=("HepG2" "K562" "SKNSH")

module reset
module load miniconda
conda activate mcn_varef

cell=${cell_types[$SLURM_ARRAY_TASK_ID]}

echo "[+] Processing $cell..."
#make the specification autosql files
echo "table SKNSH_MPAC_gnomAd" > ${cell}.as
echo "\"MPAC variant effect predictions for all gnomad variants in cell line ${cell}\"" >> ${cell}.as
cat specification_columns.txt >> ${cell}.as
#now convert the bed file to bigbed
bedToBigBed -as=${cell}.as -type=bed9+4 /home/mcn26/varef/data/ucsc/pre_bigbed_bed/${cell}.bed hg38.chrom.sizes /home/mcn26/varef/data/ucsc/bigbed/${cell}.bb


