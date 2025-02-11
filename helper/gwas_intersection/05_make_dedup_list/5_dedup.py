#!/usr/bin/env python
# coding: utf-8

# In[10]:


import os
import subprocess
import requests
#start the database
process = subprocess.Popen(["postgres", "-D", "/home/mcn26/palmer_scratch/db", "-p", "5433"])
# Load the SQL extension
get_ipython().run_line_magic('load_ext', 'sql')
#dealing with a weird bug
get_ipython().run_line_magic('config', "SqlMagic.style = '_DEPRECATED_DEFAULT'")


# In[ ]:


print("[!] Waiting 120s for database server to start", flush=True)


# In[2]:


import time
time.sleep(120)


# In[ ]:


print("[!] Attempting to connect", flush=True)


# In[12]:


get_ipython().run_cell_magic('sql', '', 'postgresql://mr_root:password@localhost:5433/scratch\n')


# In[ ]:


print("[+] Connected.", flush=True)


# In[9]:


get_ipython().run_cell_magic('sql', '', "SET max_parallel_workers = 16;\nSET max_parallel_workers_per_gather = 6;\nSET parallel_setup_cost = 100;\nSET parallel_tuple_cost = 0.1;\nSET work_mem = '1GB';\nSET maintenance_work_mem = '4GB';\nSET effective_cache_size = '48GB';\nSET shared_buffers = '16GB';\nSET enable_parallel_hash = ON;\nSET enable_parallel_seqscan = ON;\nSET enable_parallel_append = ON;\n")


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'SET max_parallel_workers_per_gather = 5;\n')


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'DROP VIEW IF EXISTS  unique_id_malin_gnomad;\n')


# In[ ]:


print("[+] clustering", flush=True)


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'CLUSTER malin_gnomad USING idx_id;\n')


# In[ ]:


print("[+] finished", flush=True)
print("[+] creating intermediate table", flush=True)


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'CREATE TABLE intermediate_unique_ids AS\nSELECT id\nFROM malin_gnomad\nGROUP BY id\nHAVING COUNT(*) = 1;\n')


# In[ ]:


print("[+] finished", flush=True)
print("[+] creating index", flush=True)


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'CREATE INDEX idx_intermediate_unique_ids ON intermediate_unique_ids(id);\n')


# In[ ]:


print("[+] finished", flush=True)
print("[+] creating mat view", flush=True)


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'CREATE MATERIALIZED VIEW unique_id_malin_gnomad AS\nSELECT *\nFROM malin_gnomad\nWHERE id IN (SELECT id FROM intermediate_unique_ids);\n')


# In[ ]:


print("FINISHED ALL TASKS, SHUTTING SERVER DOWN", flush=True)


# In[13]:


get_ipython().system('pg_ctl -D ~/palmer_scratch/db stop')

