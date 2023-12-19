## ideas

Partitioning and bucketing
- Bucket on chrom key, step prior to annotation?
- alternatively, partition in memory before merging

Broadcast join?
- Smaller dataset is /home/mcn26/varef/data/ENCODE/SCREEN_v4_cCREs_agnostic/GRCh38-cCREs.V4.bed.gz
- Only 124 MB. Can definitely try
- [x] Implemented

cache() genomic regions in memory?
- break `regions_subset = regions.filter( (F.col("REGION_TYPE") == name ) )` out of the function
- pre-compute & cache 
- [ ] implemented

re-write with glow or adam to use their range-joins?
- could process previous step's tables inyo real VCFs and use this approach or a cmdline tool. 

## trials


