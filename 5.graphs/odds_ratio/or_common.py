import numpy as np
import scipy.stats as sps


import graphing_config as gc

def compute_OR(df,a,a_val,b,b_val):
    """
    Essentially computes an odds-ratio for a set intersection.
    
    a & b are column names, a_val and b_val are the specific values we are considering for overlap.
    The input dataframe df must have columns `a`, `b`, and "count". Each row records the number of occurances
    for each combination of a and b. 
    
    The code will define two sets A and B, where A is the set of elements where a=a_val, and B is where b=b_val
    
    The odds-ratio table is
    A, B  !A, B
    A,!B  !A,!B
    """
    
    table=np.array([
        [df[(df[a] == a_val) & (df[b] == b_val)]["count"].sum() , df[(df[a] != a_val) & (df[b] == b_val)]["count"].sum()],
        [df[(df[a] == a_val) & (df[b] != b_val)]["count"].sum() , df[(df[a] != a_val) & (df[b] != b_val)]["count"].sum()]
    ]).astype(int)

    
    
    #we will do two computations here
    result=sps.contingency.odds_ratio(table,kind="sample")
    odds=result.statistic
    ci=result.confidence_interval(confidence_level=0.95)

    p=sps.fisher_exact(table, alternative='two-sided').pvalue
    
    return {'OR':odds,"ci_lower":ci[0],'ci_upper':ci[1],'p':p}

    #you can manually check that they are nearly the same
    #print(result)
    #print(sps.fisher_exact(table))

import sys
import math
import pandas as pd
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns



def plot_or(df,x,y,xlabel,ylim,title):
    plt.figure(figsize=(10, 6))
    sns.barplot(x=x, y=y, data=df, errorbar=None)  # errorbar=None to avoid automatic error bars

    # Determine a threshold for extremely small p-values, slightly above Python's smallest positive normal float
    min_positive_float = sys.float_info.min
    threshold_exponent = math.floor(math.log10(min_positive_float)) + 1  # Slightly higher than the minimum

    
    # Add error bars manually
    for i, (index, row) in enumerate(df.iterrows()):
        # Add error bars manually
        plt.errorbar(row[x], row[y], 
                     yerr=[[row[y] - row['ci_lower']], [row['ci_upper'] - row[y]]], 
                     fmt='o', color='black', capsize=5)

        # Handle p-value annotations
        if row['p'] == 0:
            annotation = f"p < 1e{threshold_exponent}"  # Dynamic annotation based on float precision
        else:
            exponent = math.floor(math.log10(row['p']))
            annotation = f"p < 10^{exponent}"

        plt.text(row[x], row[y] + row['ci_upper'] - row[y] + 0.1, 
                 annotation, 
                 ha='center', va='bottom')

    # Add a horizontal line at OR=1
    plt.axhline(y=1, color='red', linestyle='--')

    # Optional: Enhance plot aesthetics
    plt.xlabel(xlabel)
    plt.ylabel('Odds Ratio (OR)')
    plt.title(title)
    plt.ylim(0,ylim)
    plt.show()

def plot_or_combo(df,x,y,xlabel,region_col,title):


    #combine the two x-tick-defining variables into one...
    df['pleio_region'] = df.astype('str')['pleio'] + '_' + df['region']
    
    
    plot = sns.catplot(x='pleio_region', y='OR', data=df, hue="pleio", kind='strip',height=6, aspect=1.5)
    plt.xticks(rotation=45,ha="right")
    
    
    # Extract the list of x-tick labels as strings
    xtick_labels = [label.get_text() for label in plot.ax.get_xticklabels()]
    
    plt.axhline(y=1, color='red', linestyle='--')
    
    #iterate over all data points
    for i in range(df.shape[0]):

        # Find the index of the current 'pleio_region' in the list of x-tick labels
        pleio_region_index = xtick_labels.index(df.iloc[i]['pleio_region'])

        # Retrieve the x-coordinate for the current 'pleio_region' from the list of x-tick positions
        x = plot.ax.get_xticks()[pleio_region_index]
        
        y = df.iloc[i]['OR']
        
        
        
        plt.text(x, y+0.1, gc.p_val_to_str(df.iloc[i]['p']),  ha='left')
        
        
        x_coords=[x,x]
        y_coords=[df.iloc[i]['ci_lower'],df.iloc[i]['ci_upper']]
        
        plt.plot(x_coords,y_coords, marker = ',',color="black")
        
    plt.ylabel('Odds Ratio (OR)')
    plt.title(title)
    plt.show()
    
