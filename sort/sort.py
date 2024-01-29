#!/usr/bin/env python
# coding: utf-8

# Sorting all variants (post filtering) to facilitate creation of phyloP boxplots

# In[6]:


from pyspark.sql import SparkSession
from pyspark.sql.types import FloatType


# In[4]:


# Initialize Spark session
spark = SparkSession.builder.appName("CSV_to_Parquet").getOrCreate()

input_directory = "/gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/2.filter"

output_directory = "/gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/sorted"

# Read .csv.gz files recursively from the specified directory
df = spark.read.option("header", "true").csv(input_directory + "/*.csv/*.csv.gz", recursiveFileLookup="true")



# In[7]:


df_with_float = df.withColumn("P_ANNO", df["P_ANNO"].cast(FloatType()))


# In[8]:


sorted_df = df.sort("P_ANNO")


# In[10]:


sorted_df.write.parquet(output_directory)

# Stop the Spark session
spark.stop()

