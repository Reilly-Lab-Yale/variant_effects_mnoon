#!/bin/bash
#SBATCH -J 22anno
#SBATCH --output=slurm_22_anno_result.txt
#SBATCH --error=slurm_22_anno_error.txt
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=64
#SBATCH --mem=300G
#SBATCH -t 2-00:00:00
#SBATCH -p ycga


module load miniconda
conda activate mcn_vareff


export only_22=True

# Convert the Jupyter notebook to a Python script
jupyter nbconvert --to script ANNOTATE.ipynb

# Execute the converted Python script
spark-submit \
    --deploy-mode cluster \
    --driver-memory 5g \
    --executor-memory 5g \
    --num-executors 31 \
    --executor-cores 8 \
    --conf spark.executor.memoryOverhead=32g \
    ANNOTATE.py

# 31 executors * 8 CPUs each = 248. Round up to 256
# 31 executors * 6 gb RAM each + 5gb driver + 32 exec overhead = 223. Round up to 300.

# Remove the Python script after execution
rm ANNOTATE.py
