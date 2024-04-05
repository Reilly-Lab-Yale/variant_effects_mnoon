#!/bin/bash
#SBATCH -J biganno
#SBATCH --output=biganno_%A_%a.out
#SBATCH --error=biganno_%A_%a.err
#SBATCH --array=1-3
#SBATCH --cpus-per-task=5
#SBATCH --mem=60G
#SBATCH -t 7-00:00:00
#SBATCH -p ycga_long

module load miniconda
conda activate mcn_vareff


export which_chr="chr${SLURM_ARRAY_TASK_ID}"


# Execute the converted Python script
spark-submit \
    --driver-memory 5g \
    --executor-memory 25g \
    --num-executors 2 \
    --executor-cores 2 \
    --conf spark.executor.memoryOverhead=4g \
    ANNOTATE.py
