#!/bin/bash
#extract the columns we need
cut -d$'\t' -f 2,1,3,4,5,6,7,39 combined_file.tsv > extracted_columns_unflipped.tsv
awk 'BEGIN {FS=OFS="\t"} {temp = $1; $1 = $2; $2 = temp; print}' extracted_columns_unflipped.tsv > extracted_columns.tsv
rm extracted_columns_unflipped.tsv
