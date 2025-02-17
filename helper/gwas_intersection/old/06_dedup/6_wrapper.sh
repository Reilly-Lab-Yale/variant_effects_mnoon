#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 1-00:00:00
#SBATCH -c 4
#SBATCH --mem=64G
module load miniconda
conda activate mcn_varef


jupyter nbconvert --to script dedup.ipynb

ipython dedup.py
