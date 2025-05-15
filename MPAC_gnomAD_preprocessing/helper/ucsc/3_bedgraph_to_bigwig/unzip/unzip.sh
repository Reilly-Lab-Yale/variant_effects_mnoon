#!/bin/bash
#SBATCH --job-name=unzip_all
#SBATCH --array=0-2  # Adjust after counting files
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --mem=6G
#SBATCH -p ycga

#whoops! bedgraph2bigwig doesn't want zipped files...

ZIP_DIR="/vast/palmer/pi/reilly/VariantEffects/data/ucsc/combined_bed"

# Get list of zip files
ZIP_FILES=($(ls -1 "${ZIP_DIR}"/*.gz))
NUM_FILES=${#ZIP_FILES[@]}


ZIP_FILE="${ZIP_FILES[$SLURM_ARRAY_TASK_ID]}"

echo "Unzipping: ${ZIP_FILE}"
gunzip "${ZIP_FILE}"
