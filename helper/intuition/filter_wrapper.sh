#!/bin/bash
#SBATCH -J purf_intu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10 # Total cores (5 cores per executor * 2 executors)
#SBATCH --mem=220G # Total memory for executors plus some overhead
#SBATCH --time=1-0:00:00 # Adjust the time limit as needed
#SBATCH --partition=ycga # Adjust based on your HPC environment

module load miniconda
conda activate mcn_vareff


python pre_filter.py


