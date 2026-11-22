process SALMON_INDEX {
    container 'quay.io/biocontainers/salmon:1.10.3--haf24da9_3'

    input:
    path transcripts

    output:
    path "salmon_index"

    script:
    """
    salmon index -t ${transcripts} -i salmon_index -p ${task.cpus} --gencode
    """
}
