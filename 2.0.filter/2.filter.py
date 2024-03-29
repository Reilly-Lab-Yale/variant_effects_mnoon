#!/usr/bin/env python
# coding: utf-8

# The purpose of this script is to remove all variants falling in regions of the genome we expect to be uninformative. This whole project is . about evolutionary conservation and malinois : an algorithm that predicts cis-regulatory activity. Any relationships between these two variables would be obscured by the presence of genetic sequnces which could affect conservation for some reason other than their cis-regulatory activity. For this reason, I will exclude exons and splice-sites (File from Dr. Rong : exons of cannonical transcripts plus 20 bases into the splice acceptor and 6 bases into the splice donor  (numbers are from MaxEntScan motifs) ).

# Load relevant libraries

# In[1]:


from pyspark.sql import SparkSession
from pyspark.sql import functions as F
import os
import json


# initalize the spark session

# In[2]:


spark = SparkSession.builder.appName("filter").getOrCreate()


# In[27]:


chromosome="NONE"



if "which_chr" in os.environ:
    chromosome=os.environ['which_chr']

if chromosome=="NONE":
    print("error : did not find which chromosome we are supposed to crunch")
    exit(-1)
else:
    print("only crunching chromosome "+chromosome)


# Load the data

# In[4]:


#loading the extended-exon bed file
#note we are discarding all information other than chromosome, start, & stop
#!!note "autosome" : we are wholey exclusing the sex chromosomes!!
exons = spark.read.csv("/home/mcn26/varef/scripts/noon_data/gencode.v44.basic.annotation.exons.splice.autosomes.v2.bed", header=False, inferSchema=True,sep="\t").select(
    F.col('_c0').alias('chromosome'),
    F.col('_c1').alias('start'),
    F.col('_c2').alias('end')
)


exons = exons.filter((F.col("chromosome") == chromosome))


# In[34]:


variant_path=f"/home/mcn26/varef/scripts/noon_data/1.annotate/batched/annotated_output_{chromosome}.csv/*"

variants=spark.read.csv(variant_path, header=True, inferSchema=True)


# Now that we have both kinds of data, we want to compare them. Specifically, we want to drop all those variants that fall within the bed intervals (extended exons, =)
# 
# Our expanded exons are in a BED file.
# BED files are 0-based
# 
# Our incoming data was taken from a VCF originally
# VCF files are 1-based

# In[14]:


x="""
Chr1        T   A   C   G   T
          | | | | | | | | | |
1 based   | 1 | 2 | 3 | 4 | 5
0 based   0   1   2   3   4
"""


# vcf pos > start 
# 
# 
# vcf pos <= end

# In[37]:


#condition : overlaps with exon
condition = (variants['POS'] > exons['start']) & \
            (variants['POS'] <= exons['end'])

#left anti-join : 
non_exonic = variants.join(exons, condition, 'left_anti')


# In[39]:


non_exonic.write.csv(f"/home/mcn26/varef/scripts/noon_data/2.filter/filtered_output_{chromosome}.csv", header=True, mode="overwrite")

