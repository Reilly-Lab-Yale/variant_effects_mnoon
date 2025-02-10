#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import subprocess
import requests
#start the database
process = subprocess.Popen(["postgres", "-D", "/home/mcn26/palmer_scratch/db", "-p", "5433"])
#postgres -D /home/mcn26/palmer_scratch/db -p 5433
# Load the SQL extension
get_ipython().run_line_magic('load_ext', 'sql')
#dealing with a weird bug
get_ipython().run_line_magic('config', "SqlMagic.style = '_DEPRECATED_DEFAULT'")


# In[2]:


print("[!] Waiting 120s for database server to start", flush=True)
import time
time.sleep(120)


# In[3]:


print("[!] Attempting to connect", flush=True)


# In[4]:


get_ipython().run_cell_magic('sql', '', 'postgresql://mr_root:password@localhost:5433/scratch\n')


# In[5]:


print("[+] Connected.", flush=True)
print("[+] Creating materialized view....", flush=True)


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'DROP VIEW IF EXISTS  unique_id_malin_gnomad;\nCREATE MATERIALIZED VIEW unique_id_malin_gnomad AS\nSELECT m.*\nFROM malin_gnomad m\nJOIN intermediate_unique_ids i ON m.id = i.id;\n')


# In[ ]:


print("[+] FINISHED ALL TASKS, SHUTTING SERVER DOWN", flush=True)


# In[1]:


get_ipython().system('pg_ctl -D ~/palmer_scratch/db stop')

