#!/bin/bash
#SBATCH -p ycga
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=8
#SBATCH -t 2:00:00
#ran aws configure
module reset
module load gcloud
run() {
  echo "[+] $*"
  "$@"
}
bucket="gs://mpac_ucsc_genome_browser"
run gsutil -m rsync -r /vast/palmer/pi/reilly/VariantEffects/data/ucsc/bigbed ${bucket}/bigbed
#run aws s3 cp /home/mcn26/varef/scripts/noon_scripts/MPAC_gnomAD_preprocessing/helper/ucsc/test.bb ${bucket}
#run aws s3 sync /vast/palmer/pi/reilly/VariantEffects/data/ucsc/combined_vcf ${bucket}/vcf
#run aws s3 sync /vast/palmer/pi/reilly/VariantEffects/data/ucsc/combined_bigwig ${bucket}/bw
