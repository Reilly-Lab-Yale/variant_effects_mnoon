#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import subprocess
import requests


# In[2]:


#start the database
process = subprocess.Popen(["postgres", "-D", "/home/mcn26/palmer_scratch/db", "-p", "5433"])


# In[3]:


# Load the SQL extension
get_ipython().run_line_magic('load_ext', 'sql')


# In[ ]:


import time
print("[+] Waiting 60s for server to start",flush=True)
time.sleep(60)


# In[4]:


get_ipython().run_cell_magic('sql', '', 'postgresql://mr_root:password@localhost:5433/scratch\n')


# In[5]:


#dealing with a weird bug
get_ipython().run_line_magic('config', "SqlMagic.style = '_DEPRECATED_DEFAULT'")


# # gnomad

# Make sure data look OK:

# In[6]:


get_ipython().run_cell_magic('sql', '', 'SELECT *\nFROM malin_gnomad\nLIMIT 5;\n')


# Create an index on gnomad for quick access

# In[ ]:


print("[+] Creating index")


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'DROP INDEX idx_id;\nCREATE INDEX idx_id ON malin_gnomad(id);\n')


# In[ ]:


get_ipython().system('pg_ctl -D ~/palmer_scratch/db stop')
print("[+] DONE. Waiting 120s for server to stop")
time.sleep(120)

