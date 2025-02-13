import sys
import math

genome_regions=["is_in_PLS","is_in_dELS","is_in_pELS","ALL"]

emvar_cata=["emVar_K562", "emVar_SKNSH", "emVar_HepG2", "ALL", "non_emvar"]
emvar_cata_simple=["emVar_K562", "emVar_SKNSH", "emVar_HepG2"]

cell_types=["mean","K562","HepG2","SKNSH"]

data_base_path="/home/mcn26/varef/scripts/noon_data/4.count/"

pickle_root="/gpfs/gibbs/pi/reilly/VariantEffects/scripts/noon_scripts/4.count/"

###convert the boolean "in CADD category" cutoff to "mosst strict CADD cutoff row is counting". 
CADD_order = ["CADD>=10","CADD>=20","CADD>=30","CADD>=40","CADD>=50"][::-1]
# We reverse the list so we check from right to left : from most to least strict
#picking the strictest category to call as our 

CADD_default='CADD<10'

rarity_order = ["SINGLETON", "ULTRARARE", "RARE", "LOW_FREQ", "COMMON"]

# Function to find the column with True value
def find_true_column(row, columns,default):
    return next((col for col in columns if row[col]), default)

rare_classes=["SINGLETON","ULTRARARE","RARE"]
common_classes=["LOW_FREQ","COMMON"]

def lump_rarity_categories(row):
    if row["category"] in rare_classes:
        return "RARE"
    elif row["category"] in common_classes :
        return "COMMON"
    else:
        assert(1==2)#unknown cata
        
        
def p_val_to_str(p,include_star=False):
    
    min_positive_float = sys.float_info.min
    threshold_exponent = math.floor(math.log10(min_positive_float)) + 1  # Slightly higher than the minimum
    
    annotation=""
    
    if include_star:
    
        if p < 0.001:
            annotation+="***"
        elif p < 0.01:
            annotation+="**"
        elif p < 0.05:
            annotation+="*"
            print("test")

        annotation+=" "
    
    if p < 0.05:
        if p == 0:
            annotation+= f"p < 1e{threshold_exponent}"  # Dynamic annotation based on float precision
        else:
            exponent = math.floor(math.log10(p))
            annotation+= f"p < 10^{exponent}"
    else:
        annotation="n.s."

    return annotation