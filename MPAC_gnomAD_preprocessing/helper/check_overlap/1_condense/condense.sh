#!/bin/bash
module load miniconda
conda activate mcn_varef

for file in "../0_split_type"/*.tsv
do
    echo "Processing $file"
    bedtools merge -i ${file} -d -1 > ${file}_merged.bed
    echo "unmerged lines:"
    wc -l ${file}

    echo "merged lines:"
    wc -l ${file}_merged.bed


done


