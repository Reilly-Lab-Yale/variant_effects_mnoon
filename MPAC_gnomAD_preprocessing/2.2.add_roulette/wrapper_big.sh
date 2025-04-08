#!/bin/bash
#SBATCH --array=1-3
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=8G
#SBATCH -t 2-00:00:00
#SBATCH -p ycga
#SBATCH --mail-user mackenzie.noon@yale.edu
#SBATCH --mail-type=END,FAIL
#SBATCH -J bRoulette


module load miniconda
conda activate mcn_varef


export which_chr="chr${SLURM_ARRAY_TASK_ID}"

jupyter nbconvert --to script add_roulette.ipynb


# Execute the converted Python script
spark-submit --executor-memory 10g --driver-memory 5g add_roulette.py
