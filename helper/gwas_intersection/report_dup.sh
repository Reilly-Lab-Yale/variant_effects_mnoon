cd /home/mcn26/varef/data/GWAS
echo "GWAS_LD_AFR_done.tsv.gz all"
zcat GWAS_LD_AFR_done.tsv.gz | wc -l
echo "GWAS_LD_AFR_done.tsv.gz dedup"
zcat GWAS_LD_AFR_done.tsv.gz | sort | uniq | wc -l

echo "GWAS_LD_ASN_done.tsv.gz all"
zcat GWAS_LD_ASN_done.tsv.gz | wc -l
echo "GWAS_LD_ASN_done.tsv.gz uniq"
zcat GWAS_LD_ASN_done.tsv.gz | sort | uniq | wc -l

echo "GWAS_LD_EUR_done.tsv.gz all"
zcat GWAS_LD_EUR_done.tsv.gz | wc -l
echo "GWAS_LD_EUR_done.tsv.gz uniq"
zcat GWAS_LD_EUR_done.tsv.gz | sort | uniq | wc -l