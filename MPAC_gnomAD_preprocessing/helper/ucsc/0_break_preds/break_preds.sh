#!/bin/bash
#SBATCH -p ycga
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=0-21
#SBATCH -t 0:30:00

module load BCFtools/1.21-GCC-12.2.0
export bcftools

run() {
  echo "[+] $*"
  "$@"
}



data_root="/home/mcn26/varef/data/Malinois/gnomAD_variants"

chromosomes=($(ls -1 ${data_root} | grep converted | grep -v tbi))

inp=${data_root}/${chromosomes[${SLURM_ARRAY_TASK_ID}]}
chr_name=$(echo ${chromosomes[${SLURM_ARRAY_TASK_ID}]} | awk -F. -v n="7" '{print $n}')

for cell_type in HepG2 K562 SKNSH
do
	outputdir="/home/mcn26/varef/data/ucsc/broken/${cell_type}"
	mkdir -p ${outputdir}
	run bcftools annotate -x ^INFO/${cell_type}__ref,^INFO/${cell_type}__alt,^INFO/${cell_type}__skew ${inp} -o ${outputdir}/${chr_name}.vcf
done

echo "[+] done."
