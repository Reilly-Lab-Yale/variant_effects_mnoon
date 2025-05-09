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

#files in the root path
run aws s3 cp hub.txt $bucket
run aws s3 cp genomes.txt $bucket
run aws s3 cp trackDb.txt $bucket

for cell_type in HepG2 K562 SKNSH
do
	#copy bcf tracklist
	run aws s3 cp trackList.txt ${bucket}/bcf/${cell_type}/trackList.txt
done
