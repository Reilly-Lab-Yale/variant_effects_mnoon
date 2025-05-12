#!/bin/bash
#SBATCH -p ycga
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=8
#SBATCH -t 2:00:00
#ran aws configure
module load awscli
export aws
run() {
  echo "[+] $*"
  "$@"
}
bucket="s3://vcf-mpac-test"
run aws s3 sync /vast/palmer/pi/reilly/VariantEffects/data/ucsc/sorted ${bucket}/bcf
run aws s3 sync /vast/palmer/pi/reilly/VariantEffects/data/ucsc/bw ${bucket}/bw
