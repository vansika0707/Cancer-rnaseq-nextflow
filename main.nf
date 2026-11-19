include { FASTP } from './modules/fastp.nf'

include { FASTQC } from './modules/fastqc.nf'

workflow {
    // Read the sample sheet and make one item per sample: (sample_name, [fastq_1, fastq_2])
    samples_ch = Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map { row ->
            tuple(row.sample, [file(row.fastq_1), file(row.fastq_2)])
        }

    FASTQC(samples_ch)
    include { FASTP } from './modules/fastp.nf'
}
