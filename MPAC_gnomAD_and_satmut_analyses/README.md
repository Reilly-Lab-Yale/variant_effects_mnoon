# Identifying non-coding variant effects at scale via machine learning models of cis-regulatory reporter assays

Code used to analyze and visualize MPAC gnomAD and saturation mutagenesis predictions. Preprint available at (XXX). MPAC predcitions available at https://doi.org/10.5281/zenodo.15178434. See complementary repository for the project https://github.com/john-c-butts/MPAC/ and https://github.com/Reilly-Lab-Yale/MPAC_gnomAD_and_satmut/tree/main/MPAC_gnomAD_preprocessing.

Last updated April 17th 2025 by Stephen Rong (stephen DOT rong AT yale DOT edu). Contact corresponding authors or me  with questions.

## Content descriptions

### Scripts
- **scripts/satmut_promoters_preprocess**: Preprocessing scripts for MPAC saturation mutagenesis predictions.
- **scripts/satmut_promoters_analysis**: Analayses and visualizations for MPAC saturation mutagenesis predictions
- **scripts/gnomAD_selection_preprocess**: Preprocessing scripts for MPAC gnomAD predictions based on summary tables from https://github.com/Reilly-Lab-Yale/MPAC_gnomAD_and_satmut/tree/main/MPAC_gnomAD_preprocessing.
- **scripts/gnomAD_selection_analysis**: Analayses and visualizations for MPAC gnomAD predictions.

### Results
- **results/satmut_promoters_preprocess**: Corresponding results folder for scripts/satmut_promoters_preprocess. 
- **results/satmut_promoters_analysis**: Corresponding results folder for scripts/satmut_promoters_analysis. 
- **results/gnomAD_selection_analysis**: Corresponding results folder for scripts/gnomAD_selection_analysis. 
- **results/gnomAD_selection_preprocess**: Corresponding results folder for scripts/gnomAD_selection_preprocess. 

### Data
- **data/gencode_filtered_regions**: Code and BED files for masking exonic and splice regions.
- **data/gnomAD_genomes_v3**: Code for redownloading gnomAD v3.1.2  VCFs and subsetting annotations.
- **data/gnomAD_mackenzie_processed**: Copy of summary tables from https://github.com/Reilly-Lab-Yale/MPAC_gnomAD_and_satmut/tree/main/MPAC_gnomAD_preprocessing.
- **data/gnomAD_miscellaneous**: Miscellaneous TF ChIP-seq and TF footprint enrichment analyses.
- **data/gnomAD_variants_predictions**: Copies of MPAC gnomAD predictions for raw set of variants.
- **data/gnomAD_variants_predictions_filtered**: Copies of MPAC gnomAD predictions for filtered set of variants.
- **data/satmut_promoters_predictions**: Copies of MPAC saturation mutagenesis variant predictions.
- **data/satmut_promoters_meme_pwms**: PWM meme files for saturation mutagenesis motif analysis.
- **data/phylo_conservation**: Zoonomia phyloP base-level annotations (not used here).
- **data/gene_constraint_metrics**: GeneBayes s_het, gnomAD LOEUF/MOEUF, and AlphaMissense gene constraint annotations.
- **data/gene_expression_catalogs**: Human Protein Atlas gene expression annotations for K562, HepG2, and SK-N-SH.
- **data/gene_regulatory_elements**: ENCODE candidate cis-regulatory element (cCRE) annotations.
- **data/disease_annotations**: ClinVar variant annotations (not used here).

## Software dependencies
Analyses performed on Yale University HPC as Slurm scripts or in RStudio.

###  Software versions
- htslib=1.21
- bedtools=v2.31.1
- gsutil=5.30
- R=4.4.1 (2024-06-14)
- Rstudio=2024.09.0+375

### R sessionInfo()
```
R version 4.4.1 (2024-06-14)
Platform: aarch64-apple-darwin20
Running under: macOS 15.3.2

Matrix products: default
BLAS:   /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRblas.0.dylib 
LAPACK: /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.0

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

time zone: Europe/London
tzcode source: internal

attached base packages:
[1] grid      stats4    stats     graphics  grDevices utils     datasets 
[8] methods   base     

other attached packages:
 [1] wrapr_2.1.0                       viridis_0.6.5                    
 [3] viridisLite_0.4.2                 vcfR_1.15.0                      
 [5] universalmotif_1.22.3             lubridate_1.9.3                  
 [7] forcats_1.0.0                     stringr_1.5.1                    
 [9] dplyr_1.1.4                       purrr_1.0.2                      
[11] readr_2.1.5                       tidyr_1.3.1                      
[13] tibble_3.2.1                      tidyverse_2.0.0                  
[15] tidyplots_0.1.2                   stringi_1.8.4                    
[17] scales_1.3.0                      plyranges_1.24.0                 
[19] patchwork_1.3.0                   memes_1.12.0                     
[21] magrittr_2.0.3                    ggthemes_5.1.0                   
[23] ggrepel_0.9.6                     ggpubr_0.6.0                     
[25] genekitr_1.2.8                    data.table_1.16.0                
[27] corrplot_0.94                     GGally_2.2.1                     
[29] ggplot2_3.5.1                     ComplexHeatmap_2.21.1            
[31] Cairo_1.6-2                       BSgenome.Hsapiens.UCSC.hg38_1.4.5
[33] BSgenome_1.72.0                   rtracklayer_1.64.0               
[35] BiocIO_1.14.0                     Biostrings_2.72.1                
[37] XVector_0.44.0                    GenomicRanges_1.56.1             
[39] GenomeInfoDb_1.40.1               IRanges_2.38.1                   
[41] S4Vectors_0.42.1                  BiocGenerics_0.50.0              

loaded via a namespace (and not attached):
  [1] fs_1.6.4                    matrixStats_1.4.1          
  [3] bitops_1.0-9                enrichplot_1.24.4          
  [5] devtools_2.4.5              httr_1.4.7                 
  [7] RColorBrewer_1.1-3          doParallel_1.0.17          
  [9] profvis_0.4.0               tools_4.4.1                
 [11] backports_1.5.0             vegan_2.6-8                
 [13] utf8_1.2.4                  R6_2.5.1                   
 [15] mgcv_1.9-1                  lazyeval_0.2.2             
 [17] permute_0.9-7               GetoptLong_1.0.5           
 [19] urlchecker_1.0.1            withr_3.0.1                
 [21] prettyunits_1.2.0           gridExtra_2.3              
 [23] cli_3.6.3                   Biobase_2.64.0             
 [25] scatterpie_0.2.4            geneset_0.2.7              
 [27] Rsamtools_2.20.0            yulab.utils_0.1.7          
 [29] gson_0.1.0                  DOSE_3.30.5                
 [31] R.utils_2.12.3              sessioninfo_1.2.2          
 [33] RSQLite_2.3.7               generics_0.1.3             
 [35] gridGraphics_0.5-1          shape_1.4.6.1              
 [37] car_3.1-3                   zip_2.3.1                  
 [39] GO.db_3.19.1                Matrix_1.7-0               
 [41] fansi_1.0.6                 abind_1.4-8                
 [43] R.methodsS3_1.8.2           lifecycle_1.0.4            
 [45] yaml_2.3.10                 carData_3.0-5              
 [47] SummarizedExperiment_1.34.0 qvalue_2.36.0              
 [49] SparseArray_1.4.8           pinfsc50_1.3.0             
 [51] blob_1.2.4                  promises_1.3.0             
 [53] crayon_1.5.3                miniUI_0.1.1.1             
 [55] lattice_0.22-6              cowplot_1.1.3              
 [57] KEGGREST_1.44.1             pillar_1.9.0               
 [59] fgsea_1.30.0                rjson_0.2.23               
 [61] codetools_0.2-20            fastmatch_1.1-4            
 [63] glue_1.8.0                  ggvenn_0.1.10              
 [65] ggfun_0.1.6                 remotes_2.5.0              
 [67] vctrs_0.6.5                 png_0.1-8                  
 [69] treeio_1.28.0               urltools_1.7.3             
 [71] gtable_0.3.5                cachem_1.1.0               
 [73] openxlsx_4.2.7.1            europepmc_0.4.3            
 [75] S4Arrays_1.4.1              mime_0.12                  
 [77] tidygraph_1.3.1             iterators_1.0.14           
 [79] ellipsis_0.3.2              nlme_3.1-166               
 [81] ggtree_3.12.0               usethis_3.0.0              
 [83] bit64_4.5.2                 progress_1.2.3             
 [85] colorspace_2.1-1            DBI_1.2.3                  
 [87] tidyselect_1.2.1            bit_4.5.0                  
 [89] compiler_4.4.1              curl_5.2.3                 
 [91] httr2_1.0.5                 xml2_1.3.6                 
 [93] DelayedArray_0.30.1         shadowtext_0.1.4           
 [95] triebeard_0.4.1             rappdirs_0.3.3             
 [97] digest_0.6.37               htmltools_0.5.8.1          
 [99] pkgconfig_2.0.3             MatrixGenerics_1.16.0      
[101] fastmap_1.2.0               rlang_1.1.4                
[103] GlobalOptions_0.1.2         htmlwidgets_1.6.4          
[105] UCSC.utils_1.0.0            shiny_1.9.1                
[107] farver_2.1.2                jsonlite_1.8.9             
[109] BiocParallel_1.38.0         GOSemSim_2.30.2            
[111] R.oo_1.26.0                 RCurl_1.98-1.16            
[113] Formula_1.2-5               GenomeInfoDbData_1.2.12    
[115] ggplotify_0.1.2             munsell_0.5.1              
[117] Rcpp_1.0.13                 ape_5.8                    
[119] ggraph_2.2.1                zlibbioc_1.50.0            
[121] MASS_7.3-61                 plyr_1.8.9                 
[123] pkgbuild_1.4.4              ggstats_0.7.0              
[125] ggseqlogo_0.2               parallel_4.4.1             
[127] graphlayouts_1.2.0          splines_4.4.1              
[129] hms_1.1.3                   circlize_0.4.16            
[131] igraph_2.0.3                ggsignif_0.6.4             
[133] reshape2_1.4.4              pkgload_1.4.0              
[135] XML_3.99-0.17               tzdb_0.4.0                 
[137] foreach_1.5.2               tweenr_2.0.3               
[139] httpuv_1.6.15               polyclip_1.10-7            
[141] clue_0.3-65                 ggforce_0.4.2              
[143] broom_1.0.7                 xtable_1.8-4               
[145] restfulr_0.0.15             tidytree_0.4.6             
[147] rstatix_0.7.2               later_1.3.2                
[149] clusterProfiler_4.12.6      aplot_0.2.3                
[151] memoise_2.0.1               AnnotationDbi_1.66.0       
[153] GenomicAlignments_1.40.0    cluster_2.1.6              
[155] timechange_0.3.0  
```