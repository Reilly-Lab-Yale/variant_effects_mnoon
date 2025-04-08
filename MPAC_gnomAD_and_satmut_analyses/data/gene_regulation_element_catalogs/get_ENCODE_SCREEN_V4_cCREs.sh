#!/bin/sh

# download
wget -nc -P ./ http://users.wenglab.org/moorej3/Registry-cCREs-WG/V4-Files/GRCh38-CA-CTCF.V4.bed.gz
wget -nc -P ./ http://users.wenglab.org/moorej3/Registry-cCREs-WG/V4-Files/GRCh38-CA-H3K4me3.V4.bed.gz
wget -nc -P ./ http://users.wenglab.org/moorej3/Registry-cCREs-WG/V4-Files/GRCh38-CA-TF.V4.bed.gz
wget -nc -P ./ http://users.wenglab.org/moorej3/Registry-cCREs-WG/V4-Files/GRCh38-CA.V4.bed.gz
wget -nc -P ./ http://users.wenglab.org/moorej3/Registry-cCREs-WG/V4-Files/GRCh38-cCREs.V4.bed.gz
wget -nc -P ./ http://users.wenglab.org/moorej3/Registry-cCREs-WG/V4-Files/GRCh38-dELS.V4.bed.gz
wget -nc -P ./ http://users.wenglab.org/moorej3/Registry-cCREs-WG/V4-Files/GRCh38-pELS.V4.bed.gz
wget -nc -P ./ http://users.wenglab.org/moorej3/Registry-cCREs-WG/V4-Files/GRCh38-PLS.V4.bed.gz
wget -nc -P ./ http://users.wenglab.org/moorej3/Registry-cCREs-WG/V4-Files/GRCh38-TF.V4.bed.gz

# re-bgzip
gzip -d ./GRCh38-CA-CTCF.V4.bed.gz
gzip -d ./GRCh38-CA-H3K4me3.V4.bed.gz
gzip -d ./GRCh38-CA-TF.V4.bed.gz
gzip -d ./GRCh38-CA.V4.bed.gz
gzip -d ./GRCh38-cCREs.V4.bed.gz
gzip -d ./GRCh38-dELS.V4.bed.gz
gzip -d ./GRCh38-pELS.V4.bed.gz
gzip -d ./GRCh38-PLS.V4.bed.gz
gzip -d ./GRCh38-TF.V4.bed.gz

bgzip ./GRCh38-CA-CTCF.V4.bed
bgzip ./GRCh38-CA-H3K4me3.V4.bed
bgzip ./GRCh38-CA-TF.V4.bed
bgzip ./GRCh38-CA.V4.bed
bgzip ./GRCh38-cCREs.V4.bed
bgzip ./GRCh38-dELS.V4.bed
bgzip ./GRCh38-pELS.V4.bed
bgzip ./GRCh38-PLS.V4.bed
bgzip ./GRCh38-TF.V4.bed

# tabix index
tabix -p bed ./GRCh38-CA-CTCF.V4.bed.gz
tabix -p bed ./GRCh38-CA-H3K4me3.V4.bed.gz
tabix -p bed ./GRCh38-CA-TF.V4.bed.gz
tabix -p bed ./GRCh38-CA.V4.bed.gz
tabix -p bed ./GRCh38-cCREs.V4.bed.gz
tabix -p bed ./GRCh38-dELS.V4.bed.gz
tabix -p bed ./GRCh38-pELS.V4.bed.gz
tabix -p bed ./GRCh38-PLS.V4.bed.gz
tabix -p bed ./GRCh38-TF.V4.bed.gz
