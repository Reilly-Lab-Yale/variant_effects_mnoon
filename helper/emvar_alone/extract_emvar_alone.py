#!/usr/bin/env python
# coding: utf-8

# In[18]:


from pyspark.sql import SparkSession
from pyspark.sql import functions as F
import pandas as pd
import os


# Note that some of this filtering is redundant with `3.0.pleio_and_filter`, but it is being performed on an earlier step : so filtering such as is performed in `2.5.filter` is not done. 

# In[2]:


spark = SparkSession.builder.appName("extract_emvar").getOrCreate()


# In[3]:


chromosome="NONE"
#chromosome="chr22"

if "which_chr" in os.environ:
    chromosome=os.environ['which_chr']

if chromosome=="NONE":
    print("error : did not find which chromosome we are supposed to crunch")
    exit(-1)
else:
    print("only crunching chromosome "+chromosome)


# In[5]:


variant_path=f"/home/mcn26/varef/scripts/noon_data/2.0.annotate/annotated_output_{chromosome}.csv.gz/*.csv.gz"
variants=spark.read.option("delimiter","\t").csv(variant_path, header=True, inferSchema=True)


# In[6]:


#remove bad variants
variants=variants.filter(F.col("category")!="MAF_OR_AC_IS_ZERO")


# In[10]:


#remove variants without malin predictions (indels)
variants=variants.dropna(how="any",subset=["K562__ref","HepG2__ref","SKNSH__ref",
                                  "K562__alt","HepG2__alt","SKNSH__alt",
                                  "K562__skew","HepG2__skew","SKNSH__skew"])


# In[11]:


#first we compute whether each variant can be called an emvar in each cell-type. 
cell_types=["K562","SKNSH","HepG2"]
for cell_type in cell_types:
    variants = variants.withColumn(f"emVar_{cell_type}", 
                           (F.abs(F.col(f"{cell_type}__skew")) >= 0.5) & 
                           (F.greatest(F.col(f"{cell_type}__ref"), F.col(f"{cell_type}__alt")) >= 1.0))


# In[24]:


variants=variants.withColumn("any_emvar",
                    F.greatest( \
                        F.col("emVar_K562") , \
                        F.col("emVar_SKNSH"),  \
                        F.col("emVar_HepG2")
                    )
                   )


# In[26]:


#with pd.option_context('display.max_rows', None, 'display.max_columns', None):
#	display(variants.limit(20).toPandas())


# In[ ]:


columns_to_keep=["CHROM","POS","ID","REF","ALT","any_emvar"]
variants = variants.select(columns_to_keep)


# In[ ]:


output_root="/home/mcn26/varef/scripts/noon_data/emvar_alone/"

variants.repartition(1).write \
    .option("header","true") \
    .option("delimiter","\t") \
    .option("compression", "gzip") \
    .csv(output_root+chromosome)

spark.stop()

