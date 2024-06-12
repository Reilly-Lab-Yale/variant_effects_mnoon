#!/bin/bash
#SBATCH --array=1-22
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH -t 1-00:00:00
#SBATCH -p ycga
#SBATCH -J manuscript_counts

module load miniconda
conda activate mcn_varef


jupyter nbconvert --to script counts.ipynb

export which_chr="chr${SLURM_ARRAY_TASK_ID}"


# Execute the converted Python script
spark-submit --executor-memory 10g --driver-memory 5g counts.py
