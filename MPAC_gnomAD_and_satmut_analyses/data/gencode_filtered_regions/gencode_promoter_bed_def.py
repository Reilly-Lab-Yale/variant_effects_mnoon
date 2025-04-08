#!/usr/bin/env python
# coding: utf-8

# In[1]:


# import packages
import os
import pandas as pd
from collections import Counter


# In[5]:


# open full gencode gff file
gff_full = pd.read_csv('../projects/Variant_Effects/sat_mut_v2/gencode_raw/gencode.v44.basic.annotation.gff3.gz',
                      comment = '#',
                      header=None,
                      sep = '\t')


# In[6]:


# filter full gencode annotations for only protein coding sequences
# append column to full df to add gene type
gff_full.loc[:,]['gene_type'] = [i.split(';')[2].split('=')[-1] for i in gff_full[8]]
gff_protein_coding = gff_full[(gff_full[2] == 'gene') &
                              (gff_full['gene_type'] == 'protein_coding')]
# len(gff_protein_coding) = 20046, matching the metadata provided for the gff
# save protein coding gff to file for easy access
#gff_protein_coding.to_csv('Variant_Effects/gencode_data/gencode.v44.protein.coding.gff3',
#                         index=False,
#                         header=None,
#                         sep = '\t')


# In[62]:


# get list of protein coding gene names
protein_coding_genes = [i.split(';')[3].split('=')[-1] for i in gff_protein_coding[8]]
# add gene names to full gff
gff_full['gene'] = [i.split(';')[3].split('=')[-1] for i in gff_full[8]]
# filter full GFF for protein coding genes
gff_full_protein_coding = gff_full[gff_full['gene_type'] == 'protein_coding']
# make dictionary of gene name : gene type pair
gene_gene_id_dict = dict(zip([str(i).split(';')[1].split('=')[-1] for i in gff_full_protein_coding[8]],
                            [i for i in gff_full_protein_coding['gene']]))
# filter protein coding genes for 'gene_id'
gff_protein_coding_gene_ids = [str(i).split(';')[1].split('=')[-1] for i in gff_full_protein_coding[8]]
# get all exons of protein coding genes
gff_protein_coding_exons = gff_full[(gff_full['gene_type'].isin(gff_protein_coding_gene_ids)) &
                                   (gff_full[2] == 'exon')]
# filter protein coding exons for only autosomes
autosomes = [f'chr{i}' for i in range(1,23)]
gff_protein_coding_exons = gff_protein_coding_exons[gff_protein_coding_exons[0].isin(autosomes)]
# filter full gff for BED file
gff_protein_coding_exon_bed = pd.DataFrame({0 : gff_protein_coding_exons[0],
                                           1 : gff_protein_coding_exons[3],
                                           2 : gff_protein_coding_exons[4],
                                           3 : [gene_gene_id_dict.get(i) for i in gff_protein_coding_exons['gene_type']],
                                           4 : ['.' for i in range(len(gff_protein_coding_exons))],
                                           5 : gff_protein_coding_exons[6]})
# save exons BED file to disk
gff_protein_coding_exon_bed.to_csv('../projects/Variant_Effects/sat_mut_v2/gencode.v44.protein.coding.exons.autosomes.bed',
                                   sep = '\t',
                                   header=None,
                                   index=False)


# In[63]:


gff_protein_coding_exon_bed


# In[4]:


# define a function to make bed files of promoters of different sizes
def gff2promoter_bed (gff_df, promoter_size):
    # split gff into plus and minus strands for easier promoter coordinate assignation
    plus_strand_df = gff_df[gff_df[6] == '+']
    minus_strand_df = gff_df[gff_df[6] == '-']
    # make bed format df of plus strand genes
    plus_bed = pd.DataFrame({0 : plus_strand_df[0],
                             1 : [i - promoter_size for i in plus_strand_df[3]],
                             2 : plus_strand_df[3],
                             3 : [i.split(';')[3].split('=')[-1] for i in plus_strand_df[8]],
                             4 : [0 for i in range(len(plus_strand_df))],
                             5 : ['+' for i in range(len(plus_strand_df))],
                             6 : plus_strand_df[8]})
    # make bed format df of minus strand genes
    minus_bed = pd.DataFrame({0 : minus_strand_df[0],
                              1 : minus_strand_df[4],
                              2 : [i + promoter_size for i in minus_strand_df[4]],
                              3 : [i.split(';')[3].split('=')[-1] for i in minus_strand_df[8]],
                              4 : [0 for i in range(len(minus_strand_df))],
                              5 : ['-' for i in range(len(minus_strand_df))],
                              6 : minus_strand_df[8]})
    # combine bed dfs into final bed file
    full_bed = pd.concat([plus_bed, minus_bed])
    
    return full_bed


# In[9]:


# Make Promoter BED Files
# 500 bp
fiveHundred_pro_bed = gff2promoter_bed(gff_protein_coding, 500)
# 1000 bp
oneKB_pro_bed = gff2promoter_bed(gff_protein_coding, 1000)
# 5000 bp
fiveKB_pro_bed = gff2promoter_bed(gff_protein_coding, 5000)
# 10 KB
tenKB_pro_bed = gff2promoter_bed(gff_protein_coding, 10000)


# In[13]:


# Save Promoter BED files to disk
# 500bp
fiveHundred_pro_bed.to_csv('Variant_Effects/gencode_data/gencode.v44.protein.coding.500bp.promoters.bed',
                          sep = '\t',
                          index=False)
# 1000 bp
oneKB_pro_bed.to_csv('Variant_Effects/gencode_data/gencode.v44.protein.coding.1kb.promoters.bed',
                    sep = '\t',
                    index=False)
# 5000 bp
fiveKB_pro_bed.to_csv('Variant_Effects/gencode_data/gencode.v44.protein.coding.5kb.promoters.bed',
                     sep = '\t',
                     index=False)
# 10 KB
tenKB_pro_bed.to_csv('Variant_Effects/gencode_data/gencode.v44.protein.coding.10kb.promoters.bed',
                     sep = '\t',
                     index=False)

