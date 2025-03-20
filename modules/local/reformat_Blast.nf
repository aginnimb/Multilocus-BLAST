process REFORMAT_BLAST_RESULTS {
    tag "$meta.id"    


    // conda (params.enable_conda ? "conda-forge::python=3.9.5 conda-forge::pandas=1.3.5 conda-forge::biopython" : null)
    conda  "conda-forge::python=3.9.5 conda-forge::pandas=1.3.5 conda-forge::biopython"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.81' :
        'quay.io/biocontainers/biopython' }"

    input:
    tuple val(meta),path(blast_filtered)

    output:
    tuple val(meta), path('*.csv')   , emit: blast_formatted
    path "versions.yml", emit:versions
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def basename = blast_filtered.getBaseName()
    def parts = basename.tokenize('_')
    def prefix2 = parts[0..-2].join('_')
    // def prefix2 = filename.split('_')[-1].join('_')

    """
    reformat_blasthitsv2.py \\
        -blastfile $blast_filtered \\
        -outfile ./${prefix2}_formatted.csv
        $args
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}