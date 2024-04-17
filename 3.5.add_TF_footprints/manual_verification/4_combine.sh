cat extracted_header_modified.txt > final.vcf
tail -n +2 fixed_info.tsv >> final.vcf
