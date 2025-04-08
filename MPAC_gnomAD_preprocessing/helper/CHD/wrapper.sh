#!/bin/bash
#SBATCH -J chd
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=300G
#SBATCH -t 2-00:00:00
#SBATCH -p ycga

module load miniconda
conda activate mcn_varef

# Convert the Jupyter notebook to a Python script
jupyter nbconvert --to script extract_CHD.ipynb

# Execute the converted Python script
spark-submit --executor-memory 190g --driver-memory 100g extract_CHD.py
