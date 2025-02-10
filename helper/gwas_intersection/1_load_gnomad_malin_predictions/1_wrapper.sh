#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 12:00:00
#SBATCH -c 2
#SBATCH --mem-per-cpu=10G
module load miniconda
conda activate mcn_varef
# run `jupyter nbconvert --to script 2_load_gnomad_malin_predictions.ipynb`
# to convert notebook to script
ipython 2_load_gnomad_malin_predictions.py
