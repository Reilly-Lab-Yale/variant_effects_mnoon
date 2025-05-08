#!/bin/bash
#SBATCH -p ycga
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=2
#SBATCH -t 3:00:00

run() {
  echo "[+] $*"
  "$@"
}

module load BCFtools/1.21-GCC-12.2.0


cell_types=(HepG2 K562 SKNSH)

cell_type=${cell_types[${SLURM_ARRAY_TASK_ID}]}

run cd /home/mcn26/varef/data/ucsc/${cell_type}
run bcftools concat -Oz -o ${cell_type}.vcf.gz $(ls *.vcf | sort -V)
run tabix -p vcf ${cell_type}.vcf.gz
