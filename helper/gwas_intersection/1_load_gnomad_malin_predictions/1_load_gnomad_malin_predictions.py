s#!/usr/bin/env python
# coding: utf-8

# In[9]:


import os
import subprocess
import requests


# In[4]:


#start the database
process = subprocess.Popen(["postgres", "-D", "/home/mcn26/palmer_scratch/db", "-p", "5433"])


# In[10]:


# Load the SQL extension
get_ipython().run_line_magic('load_ext', 'sql')


# In[2]:


import time
print("[+] Waiting 1 min for the server to start before attempting a connection.")
time.sleep(60)


# In[5]:


get_ipython().run_cell_magic('sql', '', 'postgresql://mr_root:password@localhost:5433/scratch\n')


# In[20]:


##%%sql
##postgresql://mr_root:password@r814u09n11:5433/scratch


# In[6]:


#dealing with a weird bug
get_ipython().run_line_magic('config', "SqlMagic.style = '_DEPRECATED_DEFAULT'")


# Let's examine some lines of the gnomad data:

# In[11]:


command = "zcat /home/mcn26/varef/data/Malinois/gnomAD_variants/gnomad.genomes.v3.1.2.sites.chr10.vcf.gz | head -n2"
#command = "zcat /home/mcn26/varef/data/Malinois/gnomAD_variants/gnomad.genomes.v3.1.2.sites.chr11.converted.vcf.gz | grep -v \"##\" | head -n3"
result = subprocess.run(command, shell=True, capture_output=True, text=True)

# Print the output
print(result.stdout)


# In[6]:


get_ipython().run_cell_magic('sql', '', 'DROP TABLE malin_gnomad\n')


# In[48]:


get_ipython().run_cell_magic('sql', '', 'CREATE TABLE malin_gnomad (\n    chromosome_id TEXT,\n    pos INT,\n    id TEXT,\n    ref TEXT,\n    alt TEXT,\n    info TEXT\n)\n')


# In[51]:


get_ipython().run_cell_magic('sql', '', 'COPY malin_gnomad\nFROM PROGRAM \'ls /home/mcn26/varef/data/Malinois/gnomAD_variants/gnomad.genomes.v3.1.2.sites.*.vcf.gz | grep -v ".converted.vcf.gz" | xargs -I {} sh -c "gzip -dc {} | tail -n +2"\'\nDELIMITER E\'\\t\';\n')


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'ALTER TABLE malin_gnomad ALTER COLUMN info SET STORAGE EXTENDED;\n')


# In[1]:


print("Done :-) Stopping the server",flush=True)


# In[7]:


#stop the sql db
get_ipython().system('pg_ctl -D ~/palmer_scratch/db stop')


# In[ ]:


print("[+] Waiting 120s for the server to stop",flush=True)
time.sleep(120)

