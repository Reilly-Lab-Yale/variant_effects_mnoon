#!/bin/bash
#SBATCH -J annotate
#SBATCH --output=anno_%A_%a.out
#SBATCH --error=anno_%A_%a.err
#SBATCH --array=1-3
#SBATCH --cpus-per-task=2
#SBATCH --mem=15G
#SBATCH -t 7-00:00:00
#SBATCH -p ycga_long
#SBATCH --mail-user mackenzie.noon@yale.edu
#SBATCH --mail-type=END,FAIL


module load miniconda
conda activate mcn_varef


export which_chr="chr${SLURM_ARRAY_TASK_ID}"


# Execute the converted Python script
spark-submit --executor-memory 10g --driver-memory 5g ANNOTATE.py
