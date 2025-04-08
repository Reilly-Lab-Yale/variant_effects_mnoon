#!/usr/bin/env python
# coding: utf-8

# In[6]:


import os
import gzip
import subprocess


# In[23]:


def count_lines_using_unix(file_path):
    
    zcat_command = ['zcat', file_path]
    wc_command = ['wc', '-l']
    
    # Run zcat and pipe its output to wc
    zcat_process = subprocess.Popen(zcat_command, stdout=subprocess.PIPE)
    wc_process = subprocess.Popen(wc_command, stdin=zcat_process.stdout, stdout=subprocess.PIPE)
    
    zcat_process.stdout.close()  # Allow zcat to receive a SIGPIPE if wc_process exits
    output, _ = wc_process.communicate()
    
    
    line_count = int(output.strip()) - 1  # Subtract one for the header
    
    return line_count

def recursively_count_lines(directory):
    total_lines = 0
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.csv.gz'):
                file_path = os.path.join(root, file)
                lines_count = count_lines_using_unix(file_path)
                print(f"File: {file_path}, Lines (excluding header): {lines_count}")
                total_lines += lines_count
    return total_lines


# Manual test using a test dir of the following structure
# ```
# test_root/
# -> test.csv.gz (4 lines)
# -> inner/
# ->-> test.csv.gz (5 lines)
# ```
# Note that figures below will be one less, as I'm subtracting one since every csv I will be counting up has a header line. Also I checked and the real csv all end with a newline.

# In[25]:


print(count_lines_using_unix("./test_root/test.csv.gz"))


# In[26]:


directory_path = 'test_root'
total_lines = recursively_count_lines(directory_path)
print(f"Total lines in all .csv.gz files (excluding headers): {total_lines}")


# OK, it passes the tests. 

# In[27]:


directory_path = '/home/mcn26/varef/scripts/noon_data/3.6.remove_non_snp'
total_lines = recursively_count_lines(directory_path)
print(f"Total lines in all .csv.gz files (excluding headers): {total_lines}")

