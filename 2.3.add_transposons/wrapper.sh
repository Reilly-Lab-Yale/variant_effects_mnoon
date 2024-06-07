#!/bin/bash
#SBATCH --array=1-8,10-12
#SBATCH --cpus-per-task=6
#SBATCH --mem=100G
#SBATCH -t 4-00:00:00
#SBATCH -p ycga_long
#SBATCH --mail-user mackenzie.noon@yale.edu
#SBATCH --mail-type=END,FAIL
#SBATCH -J addrep

module load miniconda
conda activate mcn_varef

jupyter nbconvert --to script add_rep.ipynb


export which_chr="chr${SLURM_ARRAY_TASK_ID}"



# Execute the converted Python script
spark-submit --executor-memory 20g --driver-memory 5g add_rep.py
