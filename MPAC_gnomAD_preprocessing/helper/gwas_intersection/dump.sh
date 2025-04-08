#!/bin/bash
#SBATCH -p ycga_long
#SBATCH -t 8-00:00:00
#SBATCH -c 2
#SBATCH --mem-per-cpu=5G
module load miniconda
conda activate mcn_varef

postgres -D /home/mcn26/palmer_scratch/db -p 5433 &
echo '[+] Waiting 120s for server to start'
sleep 120
echo '[+] Beginning dump'
pg_dump "postgresql://mr_root:password@localhost:5433/scratch" -f /home/mcn26/palmer_scratch/post_load_broken_table.sql
echo '[+] Dump complete! Shutting down server.'
pg_ctl -D /home/mcn26/palmer_scratch/db stop &
echo '[+] Waiting 120s for server to stop.'
sleep 120
echo '[+] Zipping dump'
gzip /home/mcn26/palmer_scratch/post_load_broken_table.sql
echo '[+] Done zipping!'
conda deactivate
