#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from pyspark.sql import SparkSession
from pyspark import SparkConf, SparkContext
import pyspark.sql.functions as F 
import pyspark.sql.types as T
import os


# In[ ]:


import importlib ##can remove
import boxplot_common as bc
import graphing_config as gc
importlib.reload(bc) ##can remove
importlib.reload(gc) ##can remove


# In[ ]:


conf = SparkConf() \
    .setAppName("preprocessing_mean_phylop_vs_pleio")\

# Create a SparkContext with the specified configurations
if 'spark' in locals() and spark!=None:
    spark.stop()

sc = SparkContext(conf=conf)

# Create a SparkSession from the SparkContext
spark = SparkSession(sc)


# In[ ]:


#loading in all autosomes
#Skipping sex chromosomes, see readme
df = spark.read \
    .option("comment", "#") \
    .option("delimiter", ",") \
    .csv("/gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/3.pleio_and_filter/chr*/*.csv.gz", header=True)


# In[ ]:


int_columns=["POS","AC","AN","pleio"]
float_columns=["AF","K562__ref","HepG2__ref","SKNSH__ref","K562__alt","HepG2__alt","SKNSH__alt","K562__skew","HepG2__skew","SKNSH__skew","cadd_phred","P_ANNO","mean_ref","mean_skew","MAF"]
cre_bool_columns=[]
for column in df.columns:
    if column.startswith("is_in"):
        cre_bool_columns.append(column)
emvar_bool_columns=["emVar_K562","emVar_SKNSH","emVar_HepG2"]


# In[ ]:


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
    
    for pleio in ["ALL",0,1,2,3]:

        if pleio=="ALL":
            pass
        else:
            subset.where(F.col("pleio")==pleio)
            
        ret=bc.get_box_summary_statistics(subset,
                                  col_to_sum="P_ANNO",
                                  quantile_probs=[0.25, 0.5, 0.75],
                                  quantile_reliability=0.05)
        ret["region"]=region
        ret["pleio"]=pleio
        
        final.append(ret)


# In[ ]:


import pickle
with open("out.pkl","wb") as f:
    pickle.dump(final, f)

