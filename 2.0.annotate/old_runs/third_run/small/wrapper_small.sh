#!/bin/bash
#SBATCH -J lilanno
#SBATCH --output=lilanno_%A_%a.out
#SBATCH --error=lilanno_%A_%a.err
#SBATCH --array=11-23
#SBATCH --cpus-per-task=5
#SBATCH --mem=60G
#SBATCH -t 2-00:00:00
#SBATCH -p ycga

module load miniconda
conda activate mcn_vareff

if [ "${SLURM_ARRAY_TASK_ID}" -eq 23 ]; then
    export which_chr="chrX"
else
    export which_chr="chr${SLURM_ARRAY_TASK_ID}"
fi


# Execute the converted Python script
spark-submit \
    --driver-memory 5g \
    --executor-memory 25g \
    --num-executors 2 \
    --executor-cores 2 \
    --conf spark.executor.memoryOverhead=4g \
    ANNOTATE.py
