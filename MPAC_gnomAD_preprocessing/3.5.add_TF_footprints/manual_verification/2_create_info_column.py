import pandas as pd

# Paths to your input and output CSV files
input_csv_path = 'extracted_columns.tsv'
output_csv_path = 'fixed_info.tsv'

# Define the chunk size
chunk_size = 10000  # Adjust this based on your memory constraints

# Read and process the CSV in chunks
reader = pd.read_csv(input_csv_path, chunksize=chunk_size, delimiter="\t")

# Process each chunk
for i, chunk in enumerate(reader):
    # Modify the last column's name and prepend 'in_TF=' to each value in it
    chunk.rename(columns={chunk.columns[-1]: 'INFO'}, inplace=True)
    chunk['INFO'] = chunk['INFO'].apply(lambda x: f'in_TF={x}')
    
    # Write the chunk to file, append if it's not the first chunk
    if i == 0:
        chunk.to_csv(output_csv_path, index=False,sep="\t", mode='w')
    else:
        chunk.to_csv(output_csv_path, index=False, sep="\t", mode='a', header=False)

print(f'Modified CSV has been saved to {output_csv_path}')
