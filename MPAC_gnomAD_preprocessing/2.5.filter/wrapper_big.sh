#!/bin/bash
#SBATCH -J filter
#SBATCH --output=filter_%A_%a.out
#SBATCH --error=filter_%A_%a.err
#SBATCH --array=1-3
#SBATCH --cpus-per-task=9
#SBATCH --mem-per-cpu=4G
#SBATCH -t 72:00:00
#SBATCH -p ycga_long

module load miniconda
conda activate mcn_varef

export which_chr="chr${SLURM_ARRAY_TASK_ID}"

jupyter nbconvert --to script filter.ipynb

# Execute the converted Python script
spark-submit \
    --driver-memory 1g \
    --executor-memory 15g \
    --num-executors 2 \
    --executor-cores 4 \
    --conf spark.executor.memoryOverhead=2g \
    filter.py
