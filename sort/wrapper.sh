#!/bin/bash
#SBATCH -J sort
#SBATCH --output=sort.out
#SBATCH --error=sort.err
#SBATCH --cpus-per-task=27
#SBATCH --nodes=1
#SBATCH --mem=400G
#SBATCH -t 24:00:00
#SBATCH -p ycga

module load miniconda
conda activate mcn_vareff

jupyter nbconvert --to script sort.ipynb

# Execute the converted Python script
spark-submit \
    --driver-memory 5g \
    --executor-memory 15g \
    --num-executors 5 \
    --executor-cores 5 \
    --conf spark.executor.memoryOverhead=4g \
    sort.py