#!/bin/bash
#SBATCH -J TF
#SBATCH --output=TF_%A_%a.out
#SBATCH --error=TF_%A_%a.err
#SBATCH --array=5-22
#SBATCH --cpus-per-task=13
#SBATCH --mem=30G
#SBATCH -t 24:00:00
#SBATCH -p ycga


module load miniconda
conda activate mcn_varef

jupyter nbconvert --to script add_tf.ipynb

export which_chr="chr${SLURM_ARRAY_TASK_ID}"


# Execute the converted Python script
spark-submit \
    --driver-memory 2g \
    --executor-memory 8g \
    --num-executors 3 \
    --executor-cores 4 \
    --conf spark.executor.memoryOverhead=2g \
    add_tf.py
