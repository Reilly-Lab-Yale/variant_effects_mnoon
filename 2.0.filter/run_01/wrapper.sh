#!/bin/bash
#SBATCH -J filter
#SBATCH --output=filter_%A_%a.out
#SBATCH --error=filter_%A_%a.err
#SBATCH --array=1-22
#SBATCH --cpus-per-task=5
#SBATCH --mem=12G
#SBATCH -t 8:00:00
#SBATCH -p ycga

module load miniconda
conda activate mcn_vareff

export which_chr="chr${SLURM_ARRAY_TASK_ID}"


# Execute the converted Python script
spark-submit \
    --driver-memory 1g \
    --executor-memory 4g \
    --num-executors 2 \
    --executor-cores 2 \
    --conf spark.executor.memoryOverhead=2g \
    2.filter.py
