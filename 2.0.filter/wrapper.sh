#!/bin/bash
#SBATCH -J filter_big
#SBATCH --output=big_filter_%A_%a.out
#SBATCH --error=big_filter_%A_%a.err
#SBATCH --array=1-2
#SBATCH --cpus-per-task=5
#SBATCH --mem=12G
#SBATCH -t 72:00:00
#SBATCH -p ycga_long

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
