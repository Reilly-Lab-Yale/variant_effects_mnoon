#!/bin/bash
#SBATCH -p ycga
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=0-21
#SBATCH -t 3:00:00

module load BCFtools/1.21-GCC-12.2.0


#SLURM_ARRAY_TASK_ID=5

data_root="/home/mcn26/varef/data/ucsc"
output_dir="/home/mcn26/varef/data/ucsc/sorted"

#get the file names
#they will be the same for all 3x cell-lines
chromosomes=($(ls -1 ${data_root}/HepG2))

echo $chromosomes

for cell_type in HepG2 K562 SKNSH
do
	inp=${data_root}/${cell_type}/${chromosomes[${SLURM_ARRAY_TASK_ID}]}
	chr_name=$(echo ${chromosomes[${SLURM_ARRAY_TASK_ID}]} | awk -F. -v n="1" '{print $n}')
	out=${output_dir}/${cell_type}/${chr_name}.vcf.gz
	echo "processing ${inp}"
	echo "sorting & zipping"
	bcftools sort "$inp" -Ob -o "$out"
	echo "indexing"
	bcftools index --csi "$out"
done

echo "[+] done."
