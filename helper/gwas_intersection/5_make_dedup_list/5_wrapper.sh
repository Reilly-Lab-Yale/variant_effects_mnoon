#!/bin/bash
#SBATCH -p ycga_long
#SBATCH -t 7-00:00:00
#SBATCH -c 18
#SBATCH --mem=64G
module load miniconda
conda activate mcn_varef


jupyter nbconvert --to script 5_dedup.ipynb

ipython 5_dedup.py
