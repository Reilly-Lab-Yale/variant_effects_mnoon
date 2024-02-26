#!/usr/bin/env python
# coding: utf-8

# In[5]:


from pyspark.sql import SparkSession
from pyspark import SparkConf, SparkContext
import pyspark.sql.functions as F 
import pyspark.sql.types as T
import os


# In[6]:


import importlib ##can remove
import boxplot_common as bc
import graphing_config as gc
importlib.reload(bc) ##can remove
importlib.reload(gc) ##can remove


# In[7]:


conf = SparkConf() \
    .setAppName("pleio_vs_emvar_boxplot")\

# Create a SparkContext with the specified configurations
if 'spark' in locals() and spark!=None:
    spark.stop()

sc = SparkContext(conf=conf)

# Create a SparkSession from the SparkContext
spark = SparkSession(sc)


# In[8]:


#loading in all autosomes
#Skipping sex chromosomes, see readme
df = spark.read \
    .option("comment", "#") \
    .option("delimiter", ",") \
    .csv("/gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/3.pleio_and_filter/chr*/*.csv.gz", header=True)


# In[9]:


int_columns=["POS","AC","AN","pleio"]
float_columns=["AF","K562__ref","HepG2__ref","SKNSH__ref","K562__alt","HepG2__alt","SKNSH__alt","K562__skew","HepG2__skew","SKNSH__skew","cadd_phred","P_ANNO","mean_ref","mean_skew","MAF"]
cre_bool_columns=[]
for column in df.columns:
    if column.startswith("is_in"):
        cre_bool_columns.append(column)
        
emvar_bool_columns=["emVar_K562","emVar_SKNSH","emVar_HepG2"]


# In[10]:


for column in int_columns:
    df = df.withColumn(column, F.col(column).cast(T.IntegerType()))

for column in float_columns:
    df = df.withColumn(column, F.col(column).cast(T.FloatType()))

for column in cre_bool_columns+emvar_bool_columns:
    df = df.withColumn(column, F.col(column).cast(T.BooleanType()))


# In[ ]:


final=[]


for region in gc.genome_regions:
    subset=df
    if region!="ALL":
        subset=subset.where(F.col(region)==True)
    
    for emvar in gc.emvar_cata:

        if emvar=="ALL":
            pass
        elif emvar=="non_emvar":
            condition = ' AND '.join([f"{col_name} = False" for col_name in gc.emvar_cata_simple])
            subset = subset.filter(condition)
        else:
            subset.where(F.col(emvar)==True)
            
        ret=bc.get_box_summary_statistics(subset,
                                  col_to_sum="P_ANNO",
                                  quantile_probs=[0.25, 0.5, 0.75],
                                  quantile_reliability=0.05)
        ret["region"]=region
        ret["emvar"]=emvar
        
        final.append(ret)
    



# In[35]:


final


# In[ ]:


import pickle
with open(".pkl","wb") as f:
    pickle.dump(final, f)

