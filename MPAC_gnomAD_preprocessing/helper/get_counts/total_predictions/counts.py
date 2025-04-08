#!/usr/bin/env python
# coding: utf-8

# The purpose of this script is to extract some relevant counts to be cited in the manuscript.

# In[4]:


from pyspark.sql import SparkSession
from pyspark.sql import functions as F
import pyspark.sql.types as T
import os


# In[5]:


spark = SparkSession.builder.appName("manuscript_counts").getOrCreate()


# In[8]:


chromosome="NONE"

if "which_chr" in os.environ:
    chromosome=os.environ['which_chr']

if chromosome=="NONE":
    print("error : did not find which chromosome we are supposed to crunch")
    exit(-1)
else:
    print("only crunching chromosome "+chromosome)


# In[20]:


filename=f"/home/mcn26/varef/data/Malinois/gnomAD_variants/gnomad.genomes.v3.1.2.sites.{chromosome}.converted.vcf.gz"

#we are going to load the vcf file as a rdd first, so we can remove the comment lines 
variants_rdd = spark.sparkContext.textFile(filename)


# In[21]:


#VCFs have metadata at the beginning of the file preceeded by `##`
#Followed by a header preceeded by `#`
#then the actual data. I can't just use the regular pysaprk comment filtering
#This, and the fact that pyspark only accepts single-characters as indicating
#comments lines, means I can't use spark's builtin comment filtering.


#Grab the first 100 lines. I'm certain the header will be in here.
initial_lines = variants_rdd.take(100)
#Filter out the metadata.
filtered_initial_lines = [line for line in initial_lines if not line.startswith('##')]


# In[22]:


#Extract the header line
header_line = next(line for line in filtered_initial_lines if line.startswith('#'))
#Extract a list version the header
header = header_line[1:].split('\t')


# In[23]:


#Look up the position the data starts
start_line = initial_lines.index(header_line) + 1


# In[24]:


#manual check:
print(initial_lines[start_line-1])
print(initial_lines[start_line])


# In[25]:


#split the variants text file on tabs
split_rdd = variants_rdd.zipWithIndex().filter(lambda x: x[1] >= start_line).map(lambda x: x[0].split('\t'))


# In[28]:


#make the actual dataframe
df = spark.createDataFrame(split_rdd, schema=header)


# In[36]:


#Manual verification
df.limit(3).toPandas()#["INFO"].to_list()


# Looks good. I'm going to say that the number of rows in this dataframe is the number of variants for which we have predictions. To make certain there are no nulls, I will check the length of strings in the INFO column, which here are just predictions. 

# In[40]:


df = df.withColumn("info_length",F.length(df["INFO"]))


# In[43]:


min_max_length = df.agg(
    F.min("info_length").alias("min_length"),
    F.max("info_length").alias("max_length")
)


# In[44]:


min_max_length.show()


# In[49]:


#This code grabs & displays the min (for chr22). By manual inspection,
#It's clear it's OK, and the variance down to ~179 characters is just due to
# differences in floating point representation

#rows_with_min_length = df.filter(df["info_length"] == 179)
#rows_with_min_length.limit(3).toPandas()["INFO"].to_list()


# In[45]:


print("COUNT")
print(df.count())

