#!/bin/bash
#SBATCH -J anno
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --mem=1991G
#SBATCH -t 2-00:00:00
#SBATCH -p ycga_bigmem


module load miniconda
conda activate mcn_vareff

# Convert the Jupyter notebook to a Python script
jupyter nbconvert --to script ANNOTATE.ipynb

# Execute the converted Python script
python ANNOTATE.py

# Remove the Python script after execution
rm ANNOTATE.py
