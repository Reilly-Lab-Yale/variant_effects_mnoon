#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH -t 1-00:00:00
#SBATCH -p ycga
#SBATCH -J manuscript_counts

module load miniconda
conda activate mcn_varef


jupyter nbconvert --to script count_just_prior_to_aggregation.ipynb


# Execute the converted Python script
spark-submit --executor-memory 10g --driver-memory 5g count_just_prior_to_aggregation.py
