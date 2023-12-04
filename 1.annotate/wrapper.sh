#!/bin/bash
#SBATCH -J anno
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --mem=1991G
#SBATCH -t 12:00:00
#SBATCH -p ycga_bigmem


module load miniconda
conda activate mcn_vareff
jupyter nbconvert --execute --to notebook --inplace ANNOTATE.ipynb