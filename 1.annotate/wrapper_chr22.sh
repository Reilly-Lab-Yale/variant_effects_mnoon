#!/bin/bash
#SBATCH -J 22anno
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --mem=1991G
#SBATCH -t 2-00:00:00
#SBATCH -p ycga_bigmem


module load miniconda
conda activate mcn_vareff

# Convert the Jupyter notebook to a Python script
jupyter nbconvert --to script ANNOTATE_chr22.ipynb

# Execute the converted Python script
python ANNOTATE_chr22.py

# Remove the Python script after execution
rm ANNOTATE_chr22.py