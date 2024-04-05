#!/bin/bash
#SBATCH -J anno
#SBATCH --output=anno_%A_%a.out
#SBATCH --error=anno_%A_%a.err
#SBATCH --array=1-10
#SBATCH --cpus-per-task=5
#SBATCH --mem=12G
#SBATCH -t 1-00:00:00
#SBATCH -p ycga

module load miniconda
conda activate mcn_vareff


export which_chr="chr${SLURM_ARRAY_TASK_ID}"


# Execute the converted Python script
spark-submit \
    --driver-memory 1g \
    --executor-memory 5g \
    --num-executors 2 \
    --executor-cores 2 \
    --conf spark.executor.memoryOverhead=1g \
    ANNOTATE.py

#per thread : 5 cores, 12GB memory
# 50 cores, 120 GB memory
# rounding up to 64 cores, 140GB memory