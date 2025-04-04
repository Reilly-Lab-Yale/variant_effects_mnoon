#!/bin/bash
#SBATCH --array=22
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH -t 2-00:00:00
#SBATCH -p ycga
#SBATCH --mail-user mackenzie.noon@yale.edu
#SBATCH --mail-type=END,FAIL

inp_root="/gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/0.merge"
out_root="/gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/gwas/00_process_info_field"

which_chr="chr${SLURM_ARRAY_TASK_ID}"

file="combined.${which_chr}.vcf.gz"

# Cut out the 12th (info) column & replace `info` header with more informative
# TSV header and replace `=` format with regular tsv
# then dump back onto the disc
echo "Cutting ${file}"

zcat $inp_root/$file \
    | grep -v "^#" \
    | cut -f8 \
    | sed 's/K562__ref=/\t/' \
    | sed 's/;HepG2__ref=/\t/' \
    | sed 's/;SKNSH__ref=/\t/' \
    | sed 's/;K562__alt=/\t/' \
    | sed 's/;HepG2__alt=/\t/' \
    | sed 's/;SKNSH__alt=/\t/' \
    | sed 's/;K562__skew=/\t/' \
    | sed 's/;HepG2__skew=/\t/' \
    | sed 's/;SKNSH__skew=/\t/' \
    > ${out_root}/${file}.head


# now paste together the first 7 columns of the original file (everything before the ) and the newly broken out malin columns

#echo "pasting together..."

zcat $inp_root/$file 
    | grep -v "^#"  \
    |  cut -f1-7 \
    | paste -d '' - ${out_root}/${file}.head \
    > $out_root/${file}



##add a header line
#sed 's/^info$/\tK562__ref\tHepG2__ref\tSKNSH__ref\tK562__alt\tHepG2__alt\tSKNSH__alt\tK562__skew\tHepG2__skew\tSKNSH__skew/' \

# finally, clean up intermediate files

#rm 
#rm $out_root/${file}

echo "DONE"