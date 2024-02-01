#!/bin/bash
#SBATCH -c 32 --mem=7g
#SBATCH -t 48:00:00
#SBATCH --mail-user=mackenziecnoon@gmail.com
#SBATCH --mail-type=END,FAIL
#SBATCH -p ycga


cd ~/project

#run commands...
find /gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/2.filter -name "*.csv.gz" | parallel 'echo {} && zcat {} | wc -l'

