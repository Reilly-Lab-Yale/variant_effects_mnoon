#!/usr/bin/env python
# coding: utf-8

# This step will be moved to earlier in the pipe later. 

# In[4]:


from pyspark.sql import SparkSession
from pyspark.sql import functions as F
import pyspark.sql.types as T
import os


# In[2]:


spark = SparkSession.builder.appName("kill_non_snp").getOrCreate()


# In[5]:


chromosome="NONE"


if "which_chr" in os.environ:
    chromosome=os.environ['which_chr']

if chromosome=="NONE":
    print("error : did not find which chromosome we are supposed to crunch")
    exit(-1)
else:
    print("only crunching chromosome "+chromosome)


# In[6]:


variant_path=f"/home/mcn26/varef/scripts/noon_data/3.5add_TF_footprints/{chromosome}/*.csv.gz"
variants=spark.read.option("delimiter","\t").csv(variant_path, header=True, inferSchema=True)


# In[7]:


variants= variants.filter(
     variants.REF.isin("A", "T", "C", "G") & variants.ALT.isin("A", "T", "C", "G")
)


# In[ ]:


output_root="/home/mcn26/varef/scripts/noon_data/3.6_remove_non_snp/"

variants.write \
    .option("header","true") \
    .option("delimiter","\t") \
    .option("compression", "gzip") \
    .csv(output_root+chromosome)

spark.stop()

