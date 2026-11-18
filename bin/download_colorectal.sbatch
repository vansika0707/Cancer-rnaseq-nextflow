#!/bin/bash
#SBATCH --job-name=dl_crc
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=04:00:00
#SBATCH --output=logs/dl_crc_%j.out
#SBATCH --error=logs/dl_crc_%j.err

# Submit from the repo root, after creating the log folder:
#   mkdir -p logs && sbatch bin/download_colorectal.sbatch

set -eu
cd "$SLURM_SUBMIT_DIR"

bash bin/download_subsample.sh data/colorectal_runs.tsv 5000000 "/scratch/$USER/cancer-rnaseq/raw"
