import pyspark.sql.functions as F
def get_box_summary_statistics(df,col_to_sum,quantile_probs,quantile_reliability):

    output={}

    #quartiles
    output["quartiles"]=df.stat.approxQuantile(col_to_sum, quantile_probs, quantile_reliability) 
    
    #min
    output["min"]= df.agg(F.min(col_to_sum)).alias('min').toPandas()[f"min({col_to_sum})"][0] 


    #max
    output["max"]= df.agg(F.max(col_to_sum)).alias('max').toPandas()[f"max({col_to_sum})"][0] 

    #n
    output["n"]=df.count()

    #avg
    output["mean"]= df.agg(F.avg(col_to_sum).alias("mean")).collect()[0]['mean'] 

    #stdev
    output["stdev"]= df.agg(F.stddev_pop(col_to_sum).alias("stddev_pop")).collect()[0]['stddev_pop'] 
    
    return output