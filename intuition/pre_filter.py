## Import relevant libraries

from pyspark import SparkConf, SparkContext
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, FloatType
import pyspark.sql.functions as F
import json

## create the spark session.

spark = SparkSession.builder \
    .appName("purifying_selection_intuition_filtering") \
    .config("spark.executor.instances", "2") \
    .config("spark.executor.memory", "100g") \
    .config("spark.executor.cores", "5") \
    .config("spark.driver.memory", "16g") \
    .getOrCreate()


## Load gnomad data

schema = StructType([
    StructField("CHROM", StringType(), True),
    StructField("POS", StringType(), True),
    StructField("ID", StringType(), True),
    StructField("REF", StringType(), True),
    StructField("ALT", StringType(), True),
    StructField("QUAL", StringType(), True),
    StructField("FILTER", StringType(), True),
    StructField("INFO", StringType(), True),
])

df = spark.read \
    .option("comment", "#") \
    .option("delimiter", "\t") \
    .option("header", "false") \
    .schema(schema) \
    .csv("/gpfs/gibbs/pi/reilly/VariantEffects/data/gnomAD/gnomAD_genomes_v3.1.2/*.vcf.gz", header=False)

## Extract relevant columns from the info field

keys_to_extract = [#NONE CAN BE SUBSTRINGS OF THE OTHERS OR THE REGEX WILL BE BORKED
    "AC", "AN", "AF", "vep",
]

# Apply the regexp_extract function to the DataFrame to create new columns for each key.
# The expression '([^;]*)' captures any sequence of characters that are not a semicolon,
# which is assumed to be the delimiter for the key-value pairs in the 'INFO' column.

for key in keys_to_extract:

    #df = df.withColumn(key, regexp_extract(col("INFO"), "{}=([^;]+);?".format(key), 1))
    #when we find something put it, whne we don't put None
    df = df.withColumn(key, 
                       F.when(
                           F.regexp_extract(F.col("INFO"), "{}=([^;]+);?".format(key), 1) != "",
                           F.regexp_extract(F.col("INFO"), "{}=([^;]+);?".format(key), 1)).otherwise(None))
    
    
## Filtering out low-quality variants

df = df.filter(
    #make sure we have the necessary population stats
    (F.col("AF").isNotNull()) & 
    (F.col("AC").isNotNull()) & 
    (F.col("AN").isNotNull()) & 

    #check variant has been queried in a reasonably large number of people
    #same as gnomad's own warning threshold
    #see readme
    (F.col("AN").cast("int") >= 76156) &
    
    (F.col("AF").cast("float") !=1.0) &
    (F.col("AF").cast("float") !=0.0) &
    
    #gnomad filters passed. See original gnomad vcf header for spec.
    (F.col("FILTER") == "PASS") 
    
)

## Filtering out non-SNP variants

valid_nucleotides=["A","T","G","C"]

df=df.filter(
    ~df["REF"].isin(valid_nucleotides) &
    ~df["ALT"].isin(valid_nucleotides)
)

## dump to disc

# Save DataFrame to CSV
df.write.option("compression","gzip").csv(path='/home/mcn26/varef/scripts/noon_data/intuition_filtered.csv.gz', mode='overwrite', header=True)
