#!/bin/bash

# check if the correct number of arguments was provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <input_file> <output_file>"
  exit 1
fi

# assign the input and output file names from the command line arguments
INPUT_FILE=$1
OUTPUT_FILE=$2

# use gunzip with the -c and -d options to decompress the input file and read its contents
cat custom_gnomAD_Malinois_VCF.txt <(gunzip -cd $INPUT_FILE | tail -n +2 | awk -v OFS="\t" '{print $1,$2,$3,$4,$5,".",".",$6}') | bgzip > ${OUTPUT_FILE}

# tabix the output
tabix -p vcf $OUTPUT_FILE
