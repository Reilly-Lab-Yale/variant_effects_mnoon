#!/bin/bash
#SBATCH -J purf_intu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=300G
#SBATCH -t 2-00:00:00
#SBATCH -p ycga

module load miniconda
conda activate mcn_varef

# Convert the Jupyter notebook to a Python script
jupyter nbconvert --to script purifying_selection_intuition.ipynb

# Execute the converted Python script
python purifying_selection_intuition.py

# Remove the Python script after execution
rm purifying_selection_intuition.py
