import os

def main():
    
    with open("hub.txt","w") as f:
        f.write("""
hub MPAC predictions on gnomad variants
shortLabel MPAC on gnomad
longLabel MPAC predictions on gnomad variants
genomesFile genomes.txt
email mackenzie.noon@yale.edu
""")
    with open("genomes.txt","w") as f:
        f.write("""
genome hg38
trackDb trackDb.txt
""")
    with open("trackDb.txt","w") as f:
        #start with variants
        f.write("""
track MPAC_Variants
compositeTrack on
shortLabel MPAC variants
longLabel MPAC Predictions on gnomad variants
visibility dense
""")

        var_subtrack="""
    track {cell_type}Track
    type bcfTabix
    parent MPAC_Variants
    shortLabel {cell_type}
    longLabel {cell_type} MPAC predictions on gnomad variants
    bigDataUrl {bucket}/bcf/{cell_type}/trackList.txt
    color {color}
"""
        
        common={"bucket":"s3://vcf-mpac-test"}
        
        for cell_type,color in [("HepG2","252,167,58"),("SKNSH","233,29,35"),("K562","24,158,146")]:
            f.write(var_subtrack.format(cell_type=cell_type,color=color,**common))

        #now onto bigwigs

    #just make one tracklist: same files for all 3x sets
    with open("trackList.txt","w") as f:
        for i in os.listdir("/vast/palmer/pi/reilly/VariantEffects/data/ucsc/sorted/HepG2"):
            if i.endswith(".gz"):
                f.write(f"{i}\n")

    
if __name__=="__main__":
    main()
