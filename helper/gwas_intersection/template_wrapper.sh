#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 12:00:00
#SBATCH -c 2
#SBATCH --mem-per-cpu=10G
module load miniconda
conda activate mcn_varef


jupyter nbconvert --to script whataver.ipynb

ipython whataver.py
