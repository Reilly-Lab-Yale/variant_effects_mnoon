#!/bin/bash
#SBATCH -J annotate
#SBATCH --output=anno_%A_%a.out
#SBATCH --error=anno_%A_%a.err
#SBATCH --array=1-18
#SBATCH --cpus-per-task=2
#SBATCH --mem=100G
#SBATCH -t 2-00:00:00
#SBATCH -p ycga
#SBATCH --mail-user mackenzie.noon@yale.edu
#SBATCH --mail-type=END,FAIL


module load miniconda
conda activate mcn_varef


export which_chr="chr${SLURM_ARRAY_TASK_ID}"


# Execute the converted Python script
spark-submit --executor-memory 90g --driver-memory 9g ANNOTATE.py
