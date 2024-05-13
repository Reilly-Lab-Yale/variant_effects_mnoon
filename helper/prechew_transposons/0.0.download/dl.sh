#!/bin/bash
#SBATCH -c 5 --mem=5g
#SBATCH -t 5:00:00
#SBATCH --mail-user=mackenziecnoon@gmail.com
#SBATCH --mail-type=END,FAIL
#SBATCH -J dl


wget https://hgdownload.cse.ucsc.edu/goldenpath/hg38/bigZips/hg38.fa.out.gz


