#!/bin/bash
#SBATCH -p ycga
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=0-21
#SBATCH -t 3:00:00

module load BCFtools/1.21-GCC-12.2.0

data_root="/home/mcn26/varef/data/ucsc/sorted"
output_dir="/home/mcn26/varef/data/ucsc/bed"

#get the file names
#they will be the same for all 3x cell-lines
chromosomes=($(ls -1 ${data_root}/HepG2/ | grep -v csi))

echo $chromosomes

for cell_type in HepG2 K562 SKNSH
do
	inp=${data_root}/${cell_type}/${chromosomes[${SLURM_ARRAY_TASK_ID}]}
	chr_name=$(echo ${chromosomes[${SLURM_ARRAY_TASK_ID}]} | awk -F. -v n="1" '{print $n}')
	out=${output_dir}/${cell_type}/${chr_name}.bedgraph
	echo "processing ${inp}, spitting to ${out}"
	bcftools annotate -x ^INFO/${cell_type}__skew ${inp} \
		| grep -v '^#' \
		| awk -F'\t' -v ct="${cell_type}" 'BEGIN{OFS="\t"} {
			gsub("^" ct "__skew=", "", $8);
			print $1, $2-1, $2, $8
		}' > "${out}"
done

echo "[+] done."
