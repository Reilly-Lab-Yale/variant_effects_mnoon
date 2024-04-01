#!/bin/bash
#SBATCH -J TF
#SBATCH --output=TF_%A_%a.out
#SBATCH --error=TF_%A_%a.err
#SBATCH --array=1-22
#SBATCH --cpus-per-task=5
#SBATCH --mem=12G
#SBATCH -t 72:00:00
#SBATCH -p ycga_long

module load miniconda
conda activate mcn_varef

export which_chr="chr${SLURM_ARRAY_TASK_ID}"


# Execute the converted Python script
spark-submit \
    --driver-memory 1g \
    --executor-memory 4g \
    --num-executors 2 \
    --executor-cores 2 \
    --conf spark.executor.memoryOverhead=2g \
    add_tf.py
