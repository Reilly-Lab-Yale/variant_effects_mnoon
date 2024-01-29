#!/bin/bash

#SBATCH --job-name=gzip_csv_array
#SBATCH --output=gzip_csv_array_%A_%a.out
#SBATCH --array=0-21
#SBATCH --time=14-00:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=3000MB
#SBATCH -p ycga_long

module load pigz

# Directory containing subdirectories to process
PARENT_DIR=/home/mcn26/varef/scripts/noon_data/2.filter

# Create an array of subdirectories
IFS=$'\n' read -r -d '' -a dirs < <(find "$PARENT_DIR" -mindepth 1 -maxdepth 1 -type d && printf '\0')

# Select directory based on SLURM_ARRAY_TASK_ID
DIR_TO_PROCESS=${dirs[$SLURM_ARRAY_TASK_ID]}

# Check if the directory exists
if [ ! -d "$DIR_TO_PROCESS" ]; then
    echo "Directory does not exist: $DIR_TO_PROCESS"
    exit 1
fi

# Gzip all .csv files and remove the originals in the selected directory
cd "$DIR_TO_PROCESS"
for file in *.csv; do
    pigz "$file"
done
