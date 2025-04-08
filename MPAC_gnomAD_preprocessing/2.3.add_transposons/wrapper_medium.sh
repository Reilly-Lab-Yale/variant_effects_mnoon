#!/bin/bash
#SBATCH --array=1-8,10-11
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=10G
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
spark-submit --executor-memory 15g --driver-memory 4g add_rep.py
