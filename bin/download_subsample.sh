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
NLINES=$((N * 4))       # a FASTQ record is 4 lines. (Not named LINES: bash reserves that for terminal height.)

mkdir -p "$OUT"

# Skip the header line, then read: run, sample, patient, condition
while IFS=$'\t' read -r run sample patient condition; do
    for r in 1 2; do
        dest="$OUT/${sample}_R${r}.fastq.gz"

        if [ -s "$dest" ]; then
            echo "skip (exists): $dest"
            continue
        fi

        url="https://ftp.sra.ebi.ac.uk/vol1/fastq/${run:0:6}/${run}/${run}_${r}.fastq.gz"
        echo "downloading $sample R$r from $url"

        # Public servers sometimes drop a connection midway, so retry a few times.
        ok=0
        for attempt in 1 2 3 4 5; do
            # Write to a temp name first so a failed download never looks finished
            curl -sf "$url" | gunzip -c 2>/dev/null | head -n "$NLINES" | gzip > "$dest.tmp" || true

            # Check we really got N records (head closing the pipe makes curl complain, so we verify here)
            got=$(gunzip -c "$dest.tmp" 2>/dev/null | wc -l)
            if [ "$got" -eq "$NLINES" ]; then
                ok=1
                break
            fi
            echo "attempt $attempt failed for $sample R$r: got $got lines, expected $NLINES. Retrying in 30s." >&2
            rm -f "$dest.tmp"
            sleep 30
        done

        if [ "$ok" -ne 1 ]; then
            echo "ERROR: $sample R$r failed after 5 attempts" >&2
            exit 1
        fi
        mv "$dest.tmp" "$dest"
    done
done < <(tail -n +2 "$TSV")   # process substitution keeps the loop in the main shell, so exit 1 stops the whole script

echo "done. files in $OUT"
ls -lh "$OUT"
