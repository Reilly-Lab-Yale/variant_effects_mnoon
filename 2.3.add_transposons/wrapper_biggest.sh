#!/bin/bash
#SBATCH --array=1-4
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=10G
#SBATCH -t 7-00:00:00
#SBATCH -p ycga_long
#SBATCH --mail-user mackenzie.noon@yale.edu
#SBATCH --mail-type=END,FAIL
#SBATCH -J addrep

module load miniconda
conda activate mcn_varef

jupyter nbconvert --to script add_rep.ipynb


export which_chr="chr${SLURM_ARRAY_TASK_ID}"



# Execute the converted Python script
spark-submit --executor-memory 44g --driver-memory 5g add_rep.py
