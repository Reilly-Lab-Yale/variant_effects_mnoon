#!/bin/sh

mkdir data_download

# ClinVar 20240421 GRCh37
wget -nc -P ./ https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/clinvar_20240421.vcf.gz
wget -nc -P ./ https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/clinvar_20240421.vcf.gz.md5
wget -nc -P ./ https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/clinvar_20240421.vcf.gz.tbi
