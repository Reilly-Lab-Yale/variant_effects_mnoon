#!/bin/bash
#SBATCH -J anno
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=36
#SBATCH --mem=180G
#SBATCH -t 28-00:00:00
#SBATCH -p long


module load miniconda
conda activate mcn_vareff

# Convert the Jupyter notebook to a Python script
jupyter nbconvert --to script ANNOTATE.ipynb

# Execute the converted Python script
python ANNOTATE.py

# Remove the Python script after execution
rm ANNOTATE.py
