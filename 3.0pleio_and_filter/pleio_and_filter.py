#!/usr/bin/env python
# coding: utf-8

# In[4]:


from pyspark.sql import SparkSession
from pyspark.sql import functions as F
import os


# In[2]:


spark = SparkSession.builder.appName("pleio_and_filter").getOrCreate()


# In[6]:


chromosome="NONE"
#chromosome="chr22"

if "which_chr" in os.environ:
    chromosome=os.environ['which_chr']

if chromosome=="NONE":
    print("error : did not find which chromosome we are supposed to crunch")
    exit(-1)
else:
    print("only crunching chromosome "+chromosome)


# In[13]:


variant_path=f"/home/mcn26/varef/scripts/noon_data/2.filter/filtered_output_{chromosome}.csv/*.csv.gz"
variants=spark.read.csv(variant_path, header=True, inferSchema=True)


# ## Dropping columns with bad allele frequencies

# In[14]:


variants=variants.filter(F.col("category")!="MAF_OR_AC_IS_ZERO")


# ## Pleitropy
# 
# "Pleitropy" here refers to a variant which is an emVar in multiple cell-types. We're calling emVars as anything with abs(skew)>=0.5 and max(alt activitym ref activity)>=1

# In[15]:


#first we compute whether each variant can be called an emvar in each cell-type. 
cell_types=["K562","SKNSH","HepG2"]
for cell_type in cell_types:
    variants = variants.withColumn(f"emVar_{cell_type}", 
                           (F.abs(F.col(f"{cell_type}__skew")) >= 0.5) & 
                           (F.greatest(F.col(f"{cell_type}__ref"), F.col(f"{cell_type}__alt")) >= 1.0))

#next, we count the number of cell-types each variant is an emvar in to compute the pleitropy. 
variants = variants.withColumn("pleio", F.col("emVar_K562").cast("int") + F.col("emVar_SKNSH").cast("int") + F.col("emVar_HepG2").cast("int"))


# In[ ]:


output_root="/home/mcn26/varef/scripts/noon_data/3.pleio_and_filter/"

variants.write \
    .option("header","true") \
    .option("compression", "gzip") \
    .csv(output_root+chromosome)

spark.stop()

