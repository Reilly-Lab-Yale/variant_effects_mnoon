#!/bin/bash
#SBATCH -J preprocess
#SBATCH --output=preprocess_%A_%a.out
#SBATCH --error=preprocess_%A_%a.err
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=6G
#SBATCH -t 24:00:00
#SBATCH -p ycga

module load miniconda
conda activate mcn_vareff

# Execute the converted Python script
spark-submit \
    --driver-memory 5g \
    --executor-memory 25g \
    --num-executors 5 \
    --executor-cores 6 \
    --conf spark.executor.memoryOverhead=5g \
    preprocess.py
