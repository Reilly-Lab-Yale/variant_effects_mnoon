#!/usr/bin/env python
# coding: utf-8

# In[13]:


from pyspark import SparkConf, SparkContext
from pyspark.sql import SparkSession
import pyspark.sql.types as T
import pyspark.sql.functions as F
import os


# In[2]:


if 'spark' in locals() and spark!=None:
    spark.stop()

    #are we running the actual script, or just testing?
for_real=True

spark=None

spark = SparkSession.builder.getOrCreate()


# In[3]:


chd = spark.read \
    .option("delimiter", "\t") \
    .csv("/home/mcn26/varef/scripts/noon_data/CHD_MPRA_library_noRC.tsv", header=True)


# In[4]:


chd.take(3)


# In[ ]:


chd = chd.withColumnRenamed("id", "which")


# In[14]:


vcf_schema = T.StructType([
    T.StructField("CHROM", T.StringType(), True),
    T.StructField("POS", T.IntegerType(), True),
    T.StructField("ID", T.StringType(), True),
    T.StructField("REF", T.StringType(), True),
    T.StructField("ALT", T.StringType(), True),
    T.StructField("QUAL", T.StringType(), True),
    T.StructField("FILTER", T.StringType(), True),
    T.StructField("INFO", T.StringType(), True),

])


# In[15]:


vcf = spark.read \
    .option("comment", "#") \
    .option("delimiter", "\t") \
    .schema(vcf_schema) \
    .csv("/home/mcn26/varef/data/Malinois/gnomAD_variants/gnomad.genomes.v3.1.2.sites.*.converted.vcf.gz", header=False)


# In[22]:


vcf.take(1)


# In[24]:


#drop variants which don't have an rsID
vcf=vcf.filter(vcf.ID != ".")


# In[31]:


joined_df = chd.join(vcf, chd.seq == vcf.ID, how="left")


# In[ ]:


joined_df.write.option("codec", "org.apache.hadoop.io.compress.GzipCodec") \
    .option("delimiter", "\t") \
    .csv("chd_out.csv.gz", header=True, mode="overwrite")

