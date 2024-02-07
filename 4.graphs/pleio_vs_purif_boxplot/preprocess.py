#!/usr/bin/env python
# coding: utf-8

# In[9]:


from pyspark.sql import SparkSession
from pyspark import SparkConf, SparkContext
import pyspark.sql.functions as F 
import os


# In[10]:


conf = SparkConf() \
    .setAppName("pleio_vs_purif_boxplot")\

# Create a SparkContext with the specified configurations
if 'spark' in locals() and spark!=None:
    spark.stop()

sc = SparkContext(conf=conf)

# Create a SparkSession from the SparkContext
spark = SparkSession(sc)


# In[11]:


#loading in all autosomes
#Skipping sex chromosomes, see readme
df = spark.read \
    .option("comment", "#") \
    .option("delimiter", ",") \
    .csv("/gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/2.filter/*.csv/*.csv.gz", header=True)


# In[12]:


cell_types=["K562","SKNSH","HepG2"]
for cell_type in cell_types:
    df = df.withColumn(f"emVar_{cell_type}", 
                           (F.abs(F.col(f"{cell_type}__skew")) >= 0.5) & 
                           (F.greatest(F.col(f"{cell_type}__ref"), F.col(f"{cell_type}__alt")) >= 1.0))

#next, we count the number of cell-types each variant is an emvar in to compute the pleitropy. 
df = df.withColumn("pleio", F.col("emVar_K562").cast("int") + F.col("emVar_SKNSH").cast("int") + F.col("emVar_HepG2").cast("int"))


# In[14]:


df=df.where(F.col("category")!="MAF_OR_AC_IS_ZERO")


# In[15]:


df=df.withColumn("AF",F.col("AF").cast("float"))


# In[90]:


output={"tropy":[],"region":[],"n":[],"quartiles":[],"mean":[],"stdev":[],"min":[],"max":[]}

quantile_probs = [0.25, 0.5, 0.75]  # For quartiles
quantile_reliability = 0.05  # Adjust based on your needs

def compute(tropy,region):
    print(f"Computing {tropy} and {region}")

    output["tropy"].append(tropy)
    output["region"].append(region)

    subset=df

    if tropy!="ALL":
        subset=subset.where(F.col("pleio")==tropy)

    if region !="ALL":
        subset=subset.where(F.col(region)==True)


    #quartiles
    output["quartiles"].append(subset.stat.approxQuantile('AF', quantile_probs, quantile_reliability) )

    #min

    output["min"].append( subset.agg(F.min('AF')).alias('min').toPandas()["min(AF)"][0] )


    #max

    output["max"].append( subset.agg(F.max('AF')).alias('max').toPandas()["max(AF)"][0] )

    #n
    output["n"].append(subset.count())

    #avg
    output["mean"].append( subset.agg(F.avg("AF").alias("mean")).collect()[0]['mean'] )

    #stdev
    output["stdev"].append( subset.agg(F.stddev_pop("AF").alias("stddev_pop")).collect()[0]['stddev_pop'] )


# In[5]:


combos=[]
for tropy in ["0","1","2","ALL"]:
    for region in ["is_in_PLS","is_in_dELS","is_in_pELS","ALL"]:
        combos.append({'tropy':tropy,'region':region})
        
array_id=int(os.environ['SLURM_ARRAY_TASK_ID'])
#this call will populate `output`
compute(tropy=combos[array_id]["tropy"],region=combos[array_id]["region"])


# In[94]:


import pickle

filename=f"preprocess_pleio_{combos[array_id]['tropy']}_region_{combos[array_id]['region']}_.pkl"
print("writing f{filename}")
with open(filename, 'wb') as file:
    pickle.dump(output, file)

