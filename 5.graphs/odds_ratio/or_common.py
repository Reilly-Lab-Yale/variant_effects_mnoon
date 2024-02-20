import numpy as np
import scipy.stats as sps
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

    print(table)
    
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

