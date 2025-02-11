#!/bin/bash
#SBATCH -p ycga
#SBATCH -t 12:00:00
#SBATCH -c 1
#SBATCH --mem-per-cpu=4G

inp_root="/vast/palmer/home.mccleary/mcn26/varef/data/GWAS_malin"
#output dir is the same as input dir


#for each input file
declare -a files=("AFR.tsv"  "ASN.tsv"  "EUR.tsv")

for file in "${files[@]}"
do
    # Cut out the 12th (info) column & replace `info` header with more informative
    # CSV header and replace `=` format with regular csv
    # then dump back onto the disc
    echo "Cutting ${file}"
    cat $inp_root/$file \
        | cut -f12 \
        | sed 's/^info$/K562__ref\tHepG2__ref\tSKNSH__ref\tK562__alt\tHepG2__alt\tSKNSH__alt,\tK562__skew,\tHepG2__skew\tSKNSH__skew/' \
        | sed 's/K562__ref=/\t/' \
        | sed 's/;HepG2__ref=/\t/' \
        | sed 's/;SKNSH__ref=/\t/' \
        | sed 's/;K562__alt=/\t/' \
        | sed 's/;HepG2__alt=/\t/' \
        | sed 's/;SKNSH__alt=/\t/' \
        | sed 's/;K562__skew=/\t/' \
        | sed 's/;HepG2__skew=/\t/' \
        | sed 's/;SKNSH__skew=/\t/' \
        > ${file}.head
done

# now paste together the first 11 columns of the original file and the newly broken out malin columns
echo "pasting AFR"
cat $inp_root/AFR.tsv |  cut -f1-11 | paste - AFR.tsv.head > $inp_root/AFR_broken.tsv
echo "pasting EUR"
cat $inp_root/EUR.tsv |  cut -f1-11 | paste - EUR.tsv.head > $inp_root/EUR_broken.tsv
echo "pasting ASN"
cat $inp_root/ASN.tsv |  cut -f1-11 | paste - ASN.tsv.head > $inp_root/ASN_broken.tsv
echo "DONE"