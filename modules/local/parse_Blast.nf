process PARSE_BLAST_RESULTS {
    tag "$meta.id"
    
    conda (params.enable_conda ? "conda-forge::python=3.8.3 conda-forge::pandas conda-forge::biopython" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.81' :
        'quay.io/biocontainers/biopython' }"

    input:
    tuple val(meta),path(blastn_results)
    val(pid)

    output:
    tuple val(meta), path ('*.csv')       , emit: blast_filtered
    path "versions.yml", emit:versions

    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def prefix2 =blastn_results.getBaseName()

    """
    mkdir ${prefix}
    parse_blastn.py \\
        -blastreport $blastn_results \\
        -identity ${params.pid} \\
        -output ./${prefix2}filtered.csv

    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}