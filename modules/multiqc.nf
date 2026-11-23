process MULTIQC {
    container 'quay.io/biocontainers/multiqc:1.33--pyhdfd78af_0'

    publishDir "${params.outdir}/multiqc", mode: 'copy'

    input:
    path reports

    output:
    path "multiqc_report.html"
    path "multiqc_data"

    script:
    """
    multiqc . --force
    """
}
