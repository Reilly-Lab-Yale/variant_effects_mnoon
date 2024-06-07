#!/bin/bash
#SBATCH --array=9,13-22
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH -t 2-00:00:00
#SBATCH -p ycga
#SBATCH --mail-user mackenzie.noon@yale.edu
#SBATCH --mail-type=END,FAIL


module load miniconda
conda activate mcn_varef


jupyter nbconvert --to script remove_non_snp.ipynb

export which_chr="chr${SLURM_ARRAY_TASK_ID}"


# Execute the converted Python script
spark-submit --executor-memory 10g --driver-memory 5g remove_non_snp.py
