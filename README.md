# cancer-rnaseq-nextflow

Reproducible tumor-vs-normal RNA-seq pipeline built with Nextflow and containers.

**Steps:** FastQC -> fastp (trimming) -> Salmon (quantification) -> MultiQC -> DESeq2 -> enrichment (clusterProfiler)

## Status
Work in progress. Dataset: _TBD (GEO/SRA accession)_.

## Quick start (planned)
```bash
nextflow run . -profile test,apptainer   # on HPC
nextflow run . -profile test,docker      # where Docker is available
```

## Requirements
- Java 17+
- Nextflow >= 23.10
- Docker **or** Apptainer

## Design notes
- Every process runs in a pinned container image for reproducibility.
- Paired design in DESeq2: `~ patient + condition`.

## Results
_To be added._
