#GWAS catalog as of 2024-12-19
#parse ancestry and associations file to minimum set needed: GWAS_ancestries.tsv and GWAS_associations.tsv 
#code by SKR 
#1. combined with the ancestry label from the GWAS catalog
#2. took anything that listed asian in that category
#3. removed all tag snps that didnt have an rsID
#4. took the haploreg 1kg LD scores and filtered on LD buddies > .7
#5. joined the two sets, and added back in the tag snps too
#6. so the list is for every significant tag snp association in the gwas database, its that snp, plus all LD buddies in that same pop (it can have multiple pops)
#7. merge on rsIDs in LD_buddy collumn, (chr and pos are duplicated and only for the tag snp)
#8. remove any rsids where linakge in gnomad is ambiguous


#combine gwas ancestry file and append as an extra comma delimited collumn to the associations
awk '                                      
BEGIN {
    FS=OFS="\t";
    while (getline < "GWAS_ancestries.tsv") {
        if (!seen[$1,$2]++) {
            anc[$1] = anc[$1] ? anc[$1]","$2 : $2;
        }
    }
}
NR==1 {
    print $0, "BROAD ANCESTRAL CATEGORY";
    next;
}
NR>1 {
    print $0, anc[$1];
}' GWAS_associations.tsv > GWAS_catalog_wAncestries.tsv


#alphabetize ancestries so theyre uniform 
awk '
BEGIN {
    FS=OFS="\t";
}
function sort_array(array, n, i, j, temp) {
    n = length(array);
    for (i = 1; i <= n; i++) {
        for (j = i + 1; j <= n; j++) {
            if (array[i] > array[j]) {
                temp = array[i];
                array[i] = array[j];
                array[j] = temp;
            }
        }
    }
}
{
    # Skip the header
    if(NR == 1) {
        print;
        next;
    }

    n = split($NF, categories, ",");
    sort_array(categories);

    # Combine the sorted categories into a comma-separated string
    $NF = "";
    for (i = 1; i <= n; i++) {
        $NF = $NF ? $NF "," categories[i] : categories[i];
    }

    print;
}' GWAS_catalog_wAncestries.tsv > reformatted_GWAS_catalog_wAncestries.tsv


##############
#####ASN######
##############
grep Asian reformatted_GWAS_catalog_wAncestries.tsv> reformatted_GWAS_catalog_wAncestries_ASN.tsv
##add back in header
#PUBMEDID	STUDY	DISEASE/TRAIT	CHR_ID	CHR_POS	SNPS	P-VALUE	BROAD ANCESTRAL CATEGORY


# Separate the LD_ASN file into individual lines for each association and filter by r^2>.7 and sort
gzcat LD_ASN.tsv.gz | awk 'BEGIN { FS="\t"; OFS="\t" } 
{
    n = split($2, associations, ";")
    for (i = 1; i <= n; i++) {
        split(associations[i], snp_data, ",")
        if (snp_data[2] > 0.7) {
            print $1, snp_data[1], snp_data[2]
        }
    }
}' > LD_ASN_filtered.tsv
sort -k1,1 LD_ASN_filtered.tsv > LD_ASN_filtered_sorted.tsv 


# Prepare and Sort the GWAS File for Joining:
awk 'BEGIN { FS="\t"; OFS="\t" } NR > 1 { print $6, $0 }' reformatted_GWAS_catalog_wAncestries_ASN.tsv | sort -k1,1 > GWAS_prepared_sorted_ASN.tsv

# Join the GWAS and LD association files on the SNP column
join -t $'\t' -1 1 -2 1 GWAS_prepared_sorted_ASN.tsv LD_ASN_filtered_sorted.tsv > GWAS_LD_combined_ASN.tsv

#add in the tag snps
cat GWAS_prepared_sorted_ASN.tsv | awk '{print $0, $1, "tag"}'>  GWAS_prepared_sorted_ASN_tagLabel.tsv 
cat GWAS_LD_combined_ASN.tsv GWAS_prepared_sorted_ASN_tagLabel.tsv  > GWAS_temp_results_ASN.tsv

# Sort final set and remove entries that the tag snp does not have an rsID, and remove double tag snp line
sort GWAS_temp_results_ASN.tsv |grep '^rs' |cut -f 1,2,3,4,5,6,8,9,10,11> GWAS_LD_ASN_done.tsv

##add back in header
header="rsID\tPUBMEDID\tSTUDY\tDISEASE_TRAIT\tCHR_ID\tCHR_POS\tP-VALUE\tBROAD_ANCESTRAL_CATEGORY\tLD_BUDDY\tR2"
(echo -e "$header" ; cat  GWAS_LD_ASN_done.tsv) > done && mv done  GWAS_LD_ASN_done.tsv





##############
#####AFR######
##############
#pull any studies with a African label
grep African reformatted_GWAS_catalog_wAncestries.tsv> reformatted_GWAS_catalog_wAncestries_AFR.tsv
##add back in header
header1="PUBMEDID\tSTUDY\tDISEASE/TRAIT\tCHR_ID\tCHR_POS\tSNPS\tP-VALUE\tBROAD_ANCESTRAL_CATEGORY"
(echo -e "$header1"; cat  reformatted_GWAS_catalog_wAncestries_AFR.tsv) > temp && mv temp  reformatted_GWAS_catalog_wAncestries_AFR.tsv



# Separate the LD_AFR file into individual lines for each association and filter by r^2>.7 and sort
gzcat LD_AFR.tsv.gz | awk 'BEGIN { FS="\t"; OFS="\t" } 
{
    n = split($2, associations, ";")
    for (i = 1; i <= n; i++) {
        split(associations[i], snp_data, ",")
        if (snp_data[2] > 0.7) {
            print $1, snp_data[1], snp_data[2]
        }
    }
}' > LD_AFR_filtered.tsv
sort -k1,1 LD_AFR_filtered.tsv > LD_AFR_filtered_sorted.tsv 


# Prepare and Sort the GWAS File for Joining:
awk 'BEGIN { FS="\t"; OFS="\t" } NR > 1 { print $6, $0 }' reformatted_GWAS_catalog_wAncestries_AFR.tsv | sort -k1,1 > GWAS_prepared_sorted_AFR.tsv

# Join the GWAS and LD association files on the SNP column
join -t $'\t' -1 1 -2 1 GWAS_prepared_sorted_AFR.tsv LD_AFR_filtered_sorted.tsv > GWAS_LD_combined_AFR.tsv

#add in the tag snps
cat GWAS_prepared_sorted_AFR.tsv | awk '{print $0, $1, "tag"}'>  GWAS_prepared_sorted_AFR_tagLabel.tsv 
cat GWAS_LD_combined_AFR.tsv GWAS_prepared_sorted_AFR_tagLabel.tsv  > GWAS_temp_results_AFR.tsv

# Sort final set and remove entries that the tag snp does not have an rsID, and remove double tag snp line
sort GWAS_temp_results_AFR.tsv |grep '^rs' |cut -f 1,2,3,4,5,6,8,9,10,11> GWAS_LD_AFR_done.tsv

##add back in header
header="rsID\tPUBMEDID\tSTUDY\tDISEASE_TRAIT\tCHR_ID\tCHR_POS\tP-VALUE\tBROAD_ANCESTRAL_CATEGORY\tLD_BUDDY\tR2"
(echo -e "$header" ; cat  GWAS_LD_AFR_done.tsv) > temp && mv temp  GWAS_LD_AFR_done.tsv


##############
#####EUR######
##############
#pull any studies with a European label
grep European reformatted_GWAS_catalog_wAncestries.tsv> reformatted_GWAS_catalog_wAncestries_EUR.tsv
##add back in header
header1="PUBMEDID\tSTUDY\tDISEASE/TRAIT\tCHR_ID\tCHR_POS\tSNPS\tP-VALUE\tBROAD_ANCESTRAL_CATEGORY"
(echo -e "$header1"; cat  reformatted_GWAS_catalog_wAncestries_EUR.tsv) > temp && mv temp  reformatted_GWAS_catalog_wAncestries_EUR.tsv



# Separate the LD_EUR file into individual lines for each association and filter by r^2>.7 and sort
gzcat LD_EUR.tsv.gz | awk 'BEGIN { FS="\t"; OFS="\t" } 
{
    n = split($2, associations, ";")
    for (i = 1; i <= n; i++) {
        split(associations[i], snp_data, ",")
        if (snp_data[2] > 0.7) {
            print $1, snp_data[1], snp_data[2]
        }
    }
}' > LD_EUR_filtered.tsv
sort -k1,1 LD_EUR_filtered.tsv > LD_EUR_filtered_sorted.tsv 


# Prepare and Sort the GWAS File for Joining:
awk 'BEGIN { FS="\t"; OFS="\t" } NR > 1 { print $6, $0 }' reformatted_GWAS_catalog_wAncestries_EUR.tsv | sort -k1,1 > GWAS_prepared_sorted_EUR.tsv

# Join the GWAS and LD association files on the SNP column
join -t $'\t' -1 1 -2 1 GWAS_prepared_sorted_EUR.tsv LD_EUR_filtered_sorted.tsv > GWAS_LD_combined_EUR.tsv

#add in the tag snps
cat GWAS_prepared_sorted_EUR.tsv | awk '{print $0, $1, "tag"}'>  GWAS_prepared_sorted_EUR_tagLabel.tsv 
cat GWAS_LD_combined_EUR.tsv GWAS_prepared_sorted_EUR_tagLabel.tsv  > GWAS_temp_results_EUR.tsv

# Sort final set and remove entries that the tag snp does not have an rsID, and remove double tag snp line
sort GWAS_temp_results_EUR.tsv |grep '^rs' |cut -f 1,2,3,4,5,6,8,9,10,11> GWAS_LD_EUR_done.tsv

##add back in header
header="rsID\tPUBMEDID\tSTUDY\tDISEASE_TRAIT\tCHR_ID\tCHR_POS\tP-VALUE\tBROAD_ANCESTRAL_CATEGORY\tLD_BUDDY\tR2"
(echo -e "$header" ; cat  GWAS_LD_EUR_done.tsv) > temp && mv temp  GWAS_LD_EUR_done.tsv