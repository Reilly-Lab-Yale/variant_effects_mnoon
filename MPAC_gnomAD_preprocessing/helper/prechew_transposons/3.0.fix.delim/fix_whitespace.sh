#!/bin/bash
#SBATCH -J fixspace
#SBATCH --time=8:00:00
#SBATCH -p ycga
#SBATCH -c 1
#SBATCH --mem=4G
cd /home/mcn26/varef/data/repmask
zcat hg38.fa.out.gz | sed 's/[[:space:]]\+/\t/g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | gzip > hg38.fa.out.fixed.gz
# First sed replaces all strings of whitespace with single tabs.
# Second sed replaced leading & trailing spaces.
