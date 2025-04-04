#!/bin/bash
# Iterate over each file and output its content (skipping the header line)
for file in /gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/2.0.annotate/annotated_output_chr*.csv.gz/*.csv.gz; do
  #echo $file
  zcat "$file" | sed 1d
done