cat extracted_header.txt > final.vcf
tail -n +2 fixed_info.csv >> final.vcf
