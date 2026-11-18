#!/usr/bin/env bash
# Download the first N read pairs of each run listed in a TSV from ENA.
# Streams the data, so the full multi-GB files are never stored.
#
# Usage: bash bin/download_subsample.sh data/colorectal_runs.tsv [N_PAIRS] [OUT_DIR]
#
# Note: taking the first N reads is not a random sample. It is fine for a
# portfolio demo, and the README should say so.

set -eu

TSV=${1:?usage: download_subsample.sh runs.tsv [N_PAIRS] [OUT_DIR]}
N=${2:-5000000}
OUT=${3:-/scratch/$USER/cancer-rnaseq/raw}
LINES=$((N * 4))        # a FASTQ record is 4 lines

mkdir -p "$OUT"

# Skip the header line, then read: run, sample, patient, condition
tail -n +2 "$TSV" | while IFS=$'\t' read -r run sample patient condition; do
    for r in 1 2; do
        dest="$OUT/${sample}_R${r}.fastq.gz"

        if [ -s "$dest" ]; then
            echo "skip (exists): $dest"
            continue
        fi

        url="https://ftp.sra.ebi.ac.uk/vol1/fastq/${run:0:6}/${run}/${run}_${r}.fastq.gz"
        echo "downloading $sample R$r from $url"

        # Write to a temp name first so a failed download never looks finished
        curl -sf "$url" | gunzip -c | head -n "$LINES" | gzip > "$dest.tmp" || true

        # Check we really got N records (head closing the pipe makes curl complain, so we verify here)
        got=$(gunzip -c "$dest.tmp" | wc -l)
        if [ "$got" -ne "$LINES" ]; then
            echo "ERROR: $sample R$r has $got lines, expected $LINES" >&2
            rm -f "$dest.tmp"
            exit 1
        fi
        mv "$dest.tmp" "$dest"
    done
done

echo "done. files in $OUT"
ls -lh "$OUT"
