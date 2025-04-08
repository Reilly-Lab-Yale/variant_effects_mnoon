#!/bin/sh

# Take gnomAD tables, remap factors, collapse along dimensions, and perform statistical tests
Rscript gnomAD_purifying_selection_tables.R

# Take VEP tables, remap factors, collapse along dimensions, and perform statistical tests
Rscript gnomAD_ensembl_vep_tables.R
