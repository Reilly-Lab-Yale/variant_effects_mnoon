#!/bin/bash
#SBATCH -J pleio
#SBATCH --output=filter_%A_%a.out
#SBATCH --error=filter_%A_%a.err
#SBATCH --array=9,13-22
#SBATCH --cpus-per-task=2
#SBATCH --mem=6G
#SBATCH -t 24:00:00
#SBATCH -p ycga

module load miniconda
conda activate mcn_varef

export which_chr="chr${SLURM_ARRAY_TASK_ID}"

jupyter nbconvert --to script pleio_and_filter.ipynb


# Execute the converted Python script
spark-submit \
    --driver-memory 1g \
    --executor-memory 2g \
    --num-executors 1 \
    --executor-cores 1 \
    --conf spark.executor.memoryOverhead=2g \
    pleio_and_filter.py
