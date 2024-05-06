#!/usr/bin/env python
# coding: utf-8

# Import relevant libraries

# In[1]:


from pyspark.sql import SparkSession
from pyspark.sql import functions as F
import pyspark.sql.types as T
import os


# Create a spark session

# In[2]:


spark = SparkSession.builder \
    .appName("add_roulette") \
    .config("io.compression.codecs", "org.apache.hadoop.io.compress.GzipCodec") \
    .getOrCreate()


# In[3]:


chromosome="NONE"
chromosome="chr22"

if "which_chr" in os.environ:
    chromosome = os.environ['which_chr']

if chromosome=="NONE":
    print("error : did not find which chromosome we are supposed to crunch!")
    exit(-1)
else:
    print("only crunching chromosome "+chromosome)


# Load previous step

# In[4]:


variant_path=f'/home/mcn26/varef/scripts/noon_data/2.0.annotate/annotated_output_{chromosome}.csv.gz/*.csv.gz'
variants=spark.read.option("delimiter","\t").csv(variant_path, header=True, inferSchema=True)


# In[5]:


roulette_path=f'/home/mcn26/varef/data/roulette/{chromosome.strip("chr")}_rate_v5.2_TFBS_correction_all.vcf.gz'


# In[10]:


roulette=spark.read.option("delimiter","\t") \
    .option("comment", "#") \
    .option("compression", "gzip") \
    .csv(roulette_path, header=False, inferSchema=False)

new_columns=["CHROM","POS","ID","REF","ALT","QUAL","FILTER","INFO"]

roulette = roulette.toDF(*new_columns)


# In[11]:


roulette=roulette.drop(*["ID","QUAL","FILTER"])


# In[14]:


####The `INFO` field contains a lot of useful information, but it is all smashed together into a string. 
#Let's extract information from that string. 

keys_to_extract = [#NONE CAN BE SUBSTRINGS OF THE OTHERS
    "PN", "MR", "MG"
]

for key in keys_to_extract:

    #df = df.withColumn(key, regexp_extract(col("INFO"), "{}=([^;]+);?".format(key), 1))
    #when we find something put it, whne we don't put None
    roulette = roulette.withColumn(key, 
                       F.when(
                           F.regexp_extract(F.col("INFO"), "{}=([^;]+);?".format(key), 1) != "",
                           F.regexp_extract(F.col("INFO"), "{}=([^;]+);?".format(key), 1)).otherwise(None))


# In[18]:


roulette=roulette.drop("INFO")


# In[19]:


rename_dict={"PN":"roulette_PN","MR":"roulette_MR","MG":"roulette_MG"}

for old_name, new_name in rename_dict.items():
    roulette=roulette.withColumnRenamed(old_name,new_name)


# In[26]:


roulette=roulette.withColumn("POS", roulette["POS"].cast(T.IntegerType()))


# In[22]:


variants_annotated=variants.join(roulette,on=["CHROM","POS","REF","ALT"],how="inner")


# In[ ]:


output_root="/home/mcn26/varef/scripts/noon_data/2.2.add_roulette/"

variants_annotated.write \
    .option("header","true") \
    .option("delimiter","\t") \
    .option("compression", "gzip") \
    .csv(output_root+chromosome)

spark.stop()

