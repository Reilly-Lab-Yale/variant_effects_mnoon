#!/bin/bash
#SBATCH -J 1-2anno
#SBATCH --output=slurm_1-2_anno_result_%j.txt
#SBATCH --error=slurm_1-2_anno_error_%j.txt
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=64
#SBATCH --mem=300G
#SBATCH -t 2-00:00:00
#SBATCH -p ycga


module load miniconda
conda activate mcn_vareff


export only_1_2=True

# Execute the converted Python script
spark-submit \
    --driver-memory 5g \
    --executor-memory 5g \
    --num-executors 31 \
    --executor-cores 8 \
    --conf spark.executor.memoryOverhead=32g \
    ANNOTATE.py

# 31 executors * 8 CPUs each = 248. Round up to 256
# 31 executors * 6 gb RAM each + 5gb driver + 32 exec overhead = 223. Round up to 300.


