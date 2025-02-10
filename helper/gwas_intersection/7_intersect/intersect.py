#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import subprocess
import requests
#start the database
process = subprocess.Popen(["postgres", "-D", "/home/mcn26/palmer_scratch/db", "-p", "5433"])
# Load the SQL extension
get_ipython().run_line_magic('load_ext', 'sql')
#dealing with a weird bug
get_ipython().run_line_magic('config', "SqlMagic.style = '_DEPRECATED_DEFAULT'")


# In[2]:


print("[+] Waiting 120s for database server to start", flush=True)
import time
import datetime
print(f"[+] {datetime.datetime.now()}",flush=True)
time.sleep(120)


# In[3]:


get_ipython().run_cell_magic('sql', '', 'postgresql://mr_root:password@localhost:5433/scratch\n')


# In[3]:


get_ipython().run_cell_magic('sql', '', 'SELECT *\nFROM unique_id_malin_gnomad\nLIMIT 5;\n')


# In[16]:


get_ipython().run_cell_magic('sql', '', 'SELECT *\nFROM gwas_AFR\nLIMIT 5;\n')


# In[ ]:


print("[+] POP AFR",flush=True)
print(f"[+] {datetime.datetime.now()}",flush=True)


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'DROP TABLE merged_AFR;\n')


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'CREATE TABLE merged_AFR AS\nSELECT *\nFROM\n    gwas_AFR\nINNER JOIN\n    unique_id_malin_gnomad\nON\n    unique_id_malin_gnomad.id=gwas_AFR.rsid;\n')


# In[ ]:


print("[+] POP EUR",flush=True)
print(f"[+] {datetime.datetime.now()}",flush=True)


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'CREATE TABLE merged_EUR AS\nSELECT *\nFROM\n    gwas_EUR\nINNER JOIN\n    unique_id_malin_gnomad\nON\n    unique_id_malin_gnomad.id=gwas_EUR.rsid;\n')


# In[ ]:


print("[+] POP ASN",flush=True)
print(f"[+] {datetime.datetime.now()}",flush=True)


# In[ ]:


get_ipython().run_cell_magic('sql', '', 'CREATE TABLE merged_ASN AS\nSELECT *\nFROM\n    gwas_ASN\nINNER JOIN\n    unique_id_malin_gnomad\nON\n    unique_id_malin_gnomad.id=gwas_ASN.rsid;\n')


# In[ ]:


print("[+] DONE.",flush=True)
print(f"[+] {datetime.datetime.now()}",flush=True)


# In[4]:


get_ipython().system('pg_ctl -D ~/palmer_scratch/db stop')


# In[ ]:


print("WAITING 60s FOR SERVER TO SHUT DOWN",flush=True)
time.sleep(60)

