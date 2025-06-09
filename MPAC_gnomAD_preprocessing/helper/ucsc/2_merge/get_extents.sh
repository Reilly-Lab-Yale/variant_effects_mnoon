#!/bin/bash
#SBATCH -p ycga
#SBATCH -c 1
#SBATCH --mem=4G
#SBATCH -t 08:00:00
cd /home/mcn26/varef/data/ucsc/pre_bigbed_bed

for cell_type in HepG2 K562 SKNSH
do
    echo ${cell_type}
    awk -F'\t' 'NR==1{min=max=$12; next} {if($12<min) min=$12; if($12>max) max=$12} END{print "min:", min, "max:", max}' ${cell_type}.bed
done