#!/bin/R

# preprocess regions and annotations
Rscript preprocess_promoter_regions.R
sbatch preprocess_promoter_gnomAD.sh
sbatch preprocess_promoter_CADD.sh

# annotate variants by annotations
Rscript preprocess_promoter_pred.R
Rscript preprocess_promoter_phyloP.R
Rscript preprocess_promoter_CADD.R
Rscript preprocess_promoter_gnomAD.R
Rscript preprocess_promoter_ClinVar.R
Rscript preprocess_promoter_final.R

# annotate summaries at base, promoter, and distance level
Rscript preprocess_promoter_base.R
Rscript preprocess_promoter_prom.R
Rscript preprocess_promoter_dist.R

# annotate gene-level coding constraint and gene expression
Rscript preprocess_gene_metadata.R
