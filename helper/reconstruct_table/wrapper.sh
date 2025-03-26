#!/bin/bash
#SBATCH --array=1-22
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu=8G
#SBATCH -t 1-00:00:00
#SBATCH -p ycga
#SBATCH -J recon

#script exports variants into bed file format for rong's analyses

which_chr="chr${SLURM_ARRAY_TASK_ID}"
input_dir="/home/mcn26/varef/scripts/noon_data/3.6.remove_non_snp/${which_chr}/"
output_file="/home/mcn26/varef/scripts/noon_data/recon_bed/${which_chr}.tsv.gz"

#process

#Paranoia check: each file needs a trailing newline
echo "Checking for trailing newlines..."
for f in ${input_dir}*.csv.gz;
do
	if [ "$(zcat -- "$f" | tail -c1 | wc -l)" -eq 0 ]; then
		echo "Missing trailing newline: $f"
		exit -1
	fi
done

echo "Pass!"
echo "Processing..."

#iterate over every file
for f in ${input_dir}*.csv.gz;
do
	zcat "$f" | #cat file
		tail -n +2 | #ignore header
		awk -F'\t' 'BEGIN {OFS="\t"} { print $2, $1 - 1, $1 }' |
		gzip > ${output_file}
done

#going from POS CHROM ... to chrom start end

#Chr1        T   A   C   G   T
#          | | | | | | | | | |
#1 based   | 1 | 2 | 3 | 4 | 5
#0 based   0   1   2   3   4

#coordinates in table came from a VCF, so are 1-based
#output is chrom, pos-1, pos

