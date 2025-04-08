import os
import gzip

#first, let's combine all the "part" files for chromosome 22, for futrther manipulation.
#We don't need super parallelized I/O for our simple manual verification.


# The directory where your part-....csv.gz files are located
input_directory = '/home/mcn26/varef/scripts/noon_data/3.5add_TF_footprints/chr22'
# The path for the combined output file
output_file_path = 'combined_file.tsv'

# List all .csv.gz files in the directory
files = [f for f in os.listdir(input_directory) if f.endswith('.csv.gz')]

# Sort files to ensure header from the first file is processed first
files.sort()

# Open the output file
with open(output_file_path, 'wb') as outfile:
    for i, filename in enumerate(files):
        # Build the full path to the file
        file_path = os.path.join(input_directory, filename)
        
        # Open the .csv.gz file
        with gzip.open(file_path, 'rb') as gzfile:
            if i == 0:
                # For the first file, write everything including the header
                outfile.write(gzfile.read())
            else:
                # For subsequent files, skip the header line
                # Find the end of the first line and position the file pointer there
                gzfile.readline()  # This reads and discards the header line
                # Write the rest of the file
                outfile.write(gzfile.read())

print("Combination complete. The output file is located at:", output_file_path)
