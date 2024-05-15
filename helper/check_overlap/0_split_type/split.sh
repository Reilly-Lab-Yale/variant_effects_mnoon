file="/home/mcn26/varef/data/ENCODE/SCREEN_v4_cCREs_agnostic/GRCh38-cCREs.V4.bed.gz"
zcat $file | awk -F'\t' '{print > $6".tsv"}'
