#!/bin/bash
#SBATCH -p ycga
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=0-21
#SBATCH -t 4:00:00

module reset
module load miniconda
conda activate speedracer

#SLURM_ARRAY_TASK_ID=3

#get chromosome names from hepg2 directory, since all three cell types have the same chromosomes
chromosomes=($(ls -1 /home/mcn26/varef/data/ucsc/broken/HepG2 | sort -V))


for cell_type in HepG2 K562 SKNSH
do
	outputdir="/home/mcn26/varef/data/ucsc/pre_bigbed_bed/${cell_type}"
    output_file="${outputdir}/${chromosomes[${SLURM_ARRAY_TASK_ID}]}.bed"
    inputdir="/home/mcn26/varef/data/ucsc/broken/${cell_type}"
    input_file="${inputdir}/${chromosomes[${SLURM_ARRAY_TASK_ID}]}"
    
	mkdir -p ${outputdir}
    
    echo "[+] Converting ${input_file} > ${output_file} for ${cell_type}."
    cat ${input_file} | pypy3 vcf_to_bed.py > ${output_file}
done