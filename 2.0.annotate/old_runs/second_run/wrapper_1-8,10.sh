#!/bin/bash
#SBATCH -J anno
#SBATCH --output=anno_%A_%a.out
#SBATCH --error=anno_%A_%a.err
#SBATCH --array=1-8,10
#SBATCH --cpus-per-task=5
#SBATCH --mem=110G
#SBATCH -t 2-00:00:00
#SBATCH -p ycga

module load miniconda
conda activate mcn_vareff


export which_chr="chr${SLURM_ARRAY_TASK_ID}"


# Execute the converted Python script
spark-submit \
    --driver-memory 10g \
    --executor-memory 40g \
    --num-executors 2 \
    --executor-cores 2 \
    --conf spark.executor.memoryOverhead=10g \
    ANNOTATE.py
