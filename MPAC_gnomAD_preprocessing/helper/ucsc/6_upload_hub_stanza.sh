#!/bin/bash
module reset
module load gcloud
run() {
  echo "[+] $*"
  "$@"
}
bucket="gs://mpac_ucsc_genome_browser"

#files in the root path
run gsutil cp ucsc_hub_textfiles/hub.txt $bucket
run gsutil cp ucsc_hub_textfiles/genomes.txt $bucket
run gsutil cp ucsc_hub_textfiles/trackDb.txt $bucket
run gsutil cp ucsc_hub_textfiles/SKNSH.html $bucket
run gsutil cp ucsc_hub_textfiles/K562.html $bucket
run gsutil cp ucsc_hub_textfiles/HepG2.html $bucket
run gsutil cp ucsc_hub_textfiles/ucsc_demo.png $bucket
