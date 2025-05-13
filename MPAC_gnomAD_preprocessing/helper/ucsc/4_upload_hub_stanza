#!/bin/bash
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

