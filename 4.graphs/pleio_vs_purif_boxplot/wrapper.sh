#!/bin/bash
#SBATCH -J preprocess
#SBATCH --output=preprocess_%A_%a.out
#SBATCH --error=preprocess_%A_%a.err
#SBATCH --cpus-per-task=15
#SBATCH --mem-per-cpu=2G
#SBATCH --array=0-15
#SBATCH -t 1-00:00:00
#SBATCH -p ycga

module load miniconda
conda activate mcn_vareff


# Execute the converted Python script
spark-submit \
    --driver-memory 2g \
    --executor-memory 12g \
    --num-executors 2 \
    --executor-cores 6 \
    --conf spark.executor.memoryOverhead=2g \
    preprocess.py
