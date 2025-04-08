import gzip

# Path to your gzipped input file
input_file_path = '/home/mcn26/varef/data/Malinois/gnomAD_variants/gnomad.genomes.v3.1.2.sites.chr22.converted.vcf.gz'

# Path to your output file where extracted lines will be saved
output_file_path = 'extracted_header.txt'

# Open the gzipped input file in read mode and the output file in write mode
with gzip.open(input_file_path, 'rt', encoding='utf-8') as infile, \
     open(output_file_path, 'w', encoding='utf-8') as outfile:
    # Iterate over each line in the input file
    for line in infile:
        # Check if the line starts with '#'
        if line.startswith('#'):
            # Write the line to the output file
            outfile.write(line)
        else:
            # Stop reading further if the line does not start with '#'
            break

print(f'Extracted lines have been saved to {output_file_path}')
