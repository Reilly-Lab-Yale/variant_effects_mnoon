#!/usr/bin/env python
# coding: utf-8

# Import relevant libraries

# In[12]:


from pyspark.sql import SparkSession
from pyspark.sql import functions as F
import pyspark.sql.types as T
import os


# Create a spark session

# In[2]:


spark = SparkSession.builder.appName("add_TF").getOrCreate()


# Pick the chromosome to process

# In[3]:


chromosome="NONE"


if "which_chr" in os.environ:
    chromosome=os.environ['which_chr']

if chromosome=="NONE":
    print("error : did not find which chromosome we are supposed to crunch!")
    exit(-1)
else:
    print("only crunching chromosome "+chromosome)


# Load the chromosome

# In[4]:


variant_path=f"/gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/3.pleio_and_filter/{chromosome}/*.csv.gz"

variants=spark.read.csv(variant_path, header=True, inferSchema=True)


# In[27]:


variants


# Load the TF file.
# 
# File from Dr. Steven Rong, 
# TEMP: see slack #var-eff-reilly, 2024-03-13

# In[14]:


tf_footprint_path="/gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_data/consensus_footprints_and_motifs_hg38_GRanges.txt.gz"

tf_footprints=spark.read.option("delimiter", "\t").csv(tf_footprint_path, header=True, inferSchema=False)


# Our variant file (the chromosome we just loaded) was originally a VCF, which is 1-based.
# 
# Is our TF footprint file 0 or 1 based? I would *guess* 0-based, since it is bed-y.
# 
# Recall:
# 
# ```
# ChrZ        T   A   C   G   T
#           | | | | | | | | | |
# 1 based   | 1 | 2 | 3 | 4 | 5
# 0 based   0   1   2   3   4
# ```
# 
# 1 based vs 1-based
# 
# By inspection, we see,
# 
# 1-based : length=end-start+1
# 0-based : length=end-start
# 
# 
# Our first two rows have:
# 
# 
# ```
# 
# seqnames        start   end     width   strand  identifier      mean_signal     num_samples     num_fps summitcore_start       core_end        motif_clusters
# chr1    180788  180831  44      *       1.100643.4      92.527889       6       6       180802  180784  180808RREB1_MA0073.1;RREB1_MA0073.1;RREB1_MA0073.1;RARA_MOUSE.H11MO.0.A;TBX1_TBX_1;RR\
# EB1_MA0073.1;ZNF524_C2H2_1;TBX20_TBX_1;TBX20_TBX_5;RARA+RXRG_MA1149.1;RREB1_MA0073.1;RREB1_MA0073.1;RREB1_MA0073.1;RREB1_MA0073.1;RREB1_MA0073.1
# 
# ```
# 
# The formtting here is a little weird. 'seqnames' seems to refer to chromosome.
# 
# end-start=180831-180788=43
# 
# end-start+1 = 43+1 = width
# 
# So it's 1-based.
# 
# intersection : vcf_coord>=start && vcf_coord <= end
# 
# easy!
# 

# Cast.

# In[16]:


int_columns = ["start", "end"]

# Cast integer columns
for column in int_columns:
    tf_footprints = tf_footprints.withColumn(column, F.col(column).cast(T.IntegerType()))


# In[17]:


tf_footprints


# Subset the dataframe to the relevant portion. 

# In[19]:


# List of columns I want to keep
columns_to_keep = ["seqnames", "start", "end"]

tf_footprints = tf_footprints.select(*columns_to_keep).filter(tf_footprints["seqnames"] == chromosome)


# In[26]:


tf_footprints_broadcast = F.broadcast(tf_footprints)


# In[29]:


#employing a simple strategy where we make a table with every TF range
#in a row with every (cartesian product) then just delete those that don't fall in 
#the range. This is algorithmically boneheaded (much better algo exist w/ better time complexity), 
#but since one of the tables is small we can broadcast is which is fast. 
#so it works fine. 
joined_df = variants.crossJoin(tf_footprints_broadcast) \
    .filter((F.col("POS") >= F.col("start")) & (F.col("POS") <= F.col("end")))


# In[36]:


#now we simply select those positions that did fall in a TF
pos_in_TF = joined_df.select("POS").distinct()


# In[37]:


#and annotate the original variants dataframe with that information

#add a simple TRUE for variants in at TF motif
pos_in_TF = pos_in_TF.withColumn("in_TF", F.lit(True))

variants_annotated = variants.join(pos_in_TF, on="POS", how="left")

#those positions not found to be in any interval shold be false!
variants_annotated = variants_annotated.fillna({'in_TF': False})


# In[ ]:


#dump the data back to disc. 
output_root="/home/mcn26/varef/scripts/noon_data/3.5add_TF_footprints/"

variants_annotated.write \
    .option("header","true") \
    .option("compression", "gzip") \
    .csv(output_root+chromosome)

spark.stop()

