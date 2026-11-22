process SALMON_QUANT {
    tag "$sample"
    container 'quay.io/biocontainers/salmon:1.10.3--haf24da9_3'

    publishDir "${params.outdir}/salmon", mode: 'copy'

    input:
    tuple val(sample), path(r1), path(r2)
    path index

    output:
    tuple val(sample), path("${sample}")

    script:
    """
    salmon quant \\
        -i ${index} \\
        -l A \\
        -1 ${r1} -2 ${r2} \\
        -p ${task.cpus} \\
        --validateMappings --gcBias --seqBias \\
        -o ${sample}
    """
}
