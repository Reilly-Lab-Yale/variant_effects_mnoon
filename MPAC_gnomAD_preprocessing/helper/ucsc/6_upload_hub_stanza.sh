#!/bin/bash
module reset
module load awscli
export aws
run() {
  echo "[+] $*"
  "$@"
}
bucket="s3://vcf-mpac-test"

#files in the root path
run aws s3 cp ucsc_hub_textfiles/hub.txt $bucket
run aws s3 cp ucsc_hub_textfiles/genomes.txt $bucket
run aws s3 cp ucsc_hub_textfiles/trackDb.txt $bucket
run aws s3 cp ucsc_hub_textfiles/SKNSH.html $bucket
run aws s3 cp ucsc_hub_textfiles/K562.html $bucket
run aws s3 cp ucsc_hub_textfiles/HepG2.html $bucket
run aws s3 cp ucsc_hub_textfiles/ucsc_demo.png $bucket
