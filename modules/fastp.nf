process FASTP {
    tag "$sample"
    container 'quay.io/biocontainers/fastp:0.23.4--h5f740d0_0'

    publishDir "${params.outdir}/fastp", mode: 'copy', pattern: "*.json"

    input:
    tuple val(sample), path(reads)

    output:
    tuple val(sample), path("${sample}_R1.trimmed.fastq.gz"), path("${sample}_R2.trimmed.fastq.gz"), emit: reads
    path "${sample}.fastp.json", emit: json

    script:
    """
    fastp \\
        -i ${reads[0]} -I ${reads[1]} \\
        -o ${sample}_R1.trimmed.fastq.gz -O ${sample}_R2.trimmed.fastq.gz \\
        --json ${sample}.fastp.json \\
        --thread ${task.cpus}
    """
}
