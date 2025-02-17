#!/bin/bash
#SBATCH -c 1
#SBATCH -p ycga
#SBATCH --mem-per-cpu=8G
#SBATCH -t 4:00:00
echo "[+] loading env"
module load miniconda
conda activate mcn_varef
echo "[+] starting server"
postgres -D /home/mcn26/palmer_scratch/db -p 5433 &
echo "[+] waiting 20s for server to start"
sleep 20
echo "[+] restoring"
psql postgresql://mr_root:password@localhost:5433/scratch -f /home/mcn26/palmer_scratch/post_indexing_dump.sql
echo "[+] DONE. Killing server.."
pg_ctl -D ~/palmer_scratch/db stop
sleep 10
