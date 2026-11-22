include { FASTP } from './modules/fastp.nf'

include { FASTQC } from './modules/fastqc.nf'
include { SALMON_INDEX } from './modules/salmon_index.nf'
include { SALMON_QUANT } from './modules/salmon_quant.nf'

workflow {
    // Read the sample sheet and make one item per sample: (sample_name, [fastq_1, fastq_2])
    samples_ch = Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map { row ->
            tuple(row.sample, [file(row.fastq_1), file(row.fastq_2)])
        }

    FASTQC(samples_ch)
    FASTP(samples_ch)

    // Build the Salmon index once. A single file is treated as a "value", so it can be reused by every sample.
    SALMON_INDEX(file(params.transcripts))

        SALMON_QUANT(FASTP.out.reads, SALMON_INDEX.out)
}