
genome_regions=["is_in_PLS","is_in_dELS","is_in_pELS","ALL"]
data_base_path="/home/mcn26/varef/scripts/noon_data/3.count/"

###convert the boolean "in CADD category" cutoff to "mosst strict CADD cutoff row is counting". 
CADD_cata = ["CADD>=10","CADD>=20","CADD>=30","CADD>=40","CADD>=50"][::-1]
# We reverse the list so we check from right to left : from most to least strict
#picking the strictest category to call as our 

CADD_default='CADD<10'

# Function to find the column with True value
def find_true_column(row, columns,default):
    return next((col for col in columns if row[col]), default)

def lump_rarity_categories(row):
    if row["category"] in ["SINGLETON","ULTRARARE","RARE"]:
        return "RARE"
    elif row["category"] == "COMMON" :
        return "COMMON"
    else:
        return "not_interesting"