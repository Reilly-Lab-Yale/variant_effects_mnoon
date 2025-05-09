#!/bin/bash
#SBATCH -p ycga
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=9,14
#SBATCH -t 3:00:00

#before starting, executed
#curl https://hgdownload.soe.ucsc.edu/goldenpath/hg38/bigZips/hg38.chrom.sizes > hg38.chrom.sizes

module load miniconda
conda activate mcn_varef
#for bioconda::ucsc-bedgraphtobigwig

data_root="/home/mcn26/varef/data/ucsc/avg"
output_dir="/home/mcn26/varef/data/ucsc/bw"

#get the file names
#they will be the same for all 3x cell-lines
chromosomes=($(ls -1 ${data_root}/HepG2/))

for cell_type in HepG2 K562 SKNSH
do
	inp=${data_root}/${cell_type}/${chromosomes[${SLURM_ARRAY_TASK_ID}]}
	chr_name=$(echo ${chromosomes[${SLURM_ARRAY_TASK_ID}]} | awk -F. -v n="1" '{print $n}')
	out=${output_dir}/${cell_type}/${chr_name}.bw
	echo "in:${inp} out:${out}"
	bedGraphToBigWig ${inp} hg38.chrom.sizes ${out}
done

echo "[+] done."
