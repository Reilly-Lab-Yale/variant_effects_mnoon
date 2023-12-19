#!/bin/bash
#SBATCH -J 5_6_7anno
#SBATCH --output=slurm_5_6_7_anno_result_%j.txt
#SBATCH --error=slurm_5_6_7_anno_error_%j.txt
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=64
#SBATCH --mem=200G
#SBATCH -t 4-00:00:00
#SBATCH -p week


module load miniconda
conda activate mcn_vareff


export only_5_6_7=True

# Execute the converted Python script
spark-submit \
    --driver-memory 5g \
    --executor-memory 6g \
    --num-executors 15 \
    --executor-cores 8 \
    --conf spark.executor.memoryOverhead=32g \
    ANNOTATE.py

# 15 executors * 8 CPUs each = 120, round up to 128
# 15 executors * 6 gb RAM each + 5gb driver + 15 exec overhead = 110. Round up to 200.


