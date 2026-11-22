#!/bin/bash
#SBATCH --job-name=nf_crc
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=6G
#SBATCH --time=12:00:00
#SBATCH --output=logs/nf_crc_%j.out
#SBATCH --error=logs/nf_crc_%j.err

# This job is only the "manager". Nextflow submits each pipeline step as its own SLURM job.
# Submit from the repo root:  mkdir -p logs && sbatch bin/run_pipeline.sbatch

set -eu
cd "$SLURM_SUBMIT_DIR"
module load nextflow/25.04.6

nextflow run main.nf \
    -profile apptainer,slurm \
    --samplesheet colorectal.csv \
    --transcripts "/scratch/$USER/cancer-rnaseq/ref/gencode.v50.transcripts.fa.gz" \
    --outdir "/scratch/$USER/cancer-rnaseq/results" \
    -w "/scratch/$USER/cancer-rnaseq/work" \
    -resume
