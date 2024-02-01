awk 'NR%2{printf $0"\t"; next} 1' ./slurm* | awk -F'\t' '{sum += $2} END {print sum}'
