process BLAST_MAKEBLASTDB {
    tag "$meta"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/blast:2.15.0--pl5321h6f7f691_1':
        'biocontainers/blast:2.15.0--pl5321h6f7f691_1' }"

    input:
    tuple val(meta), path(reference_fasta)
    // path(concatenated_fasta)

    output:
    // tuple val(meta), path("${meta}/*.{ndb,nhr,nin,njs,not,nsq,ntf,nto}"), emit: db
    path("${meta}*"), emit: db_dir
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}"
    def dbdir = "${prefix}"
    // def is_compressed = fasta.getExtension() == "gz" ? true : false
    // def fasta_name = is_compressed ? fasta.getBaseName() : fasta
    """
    mkdir -p $dbdir

    makeblastdb \\
        -in ${reference_fasta} \\
        -dbtype 'nucl' \\
        -out ./$dbdir/${prefix}
        ${args}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        blast: \$(blastn -version 2>&1 | sed 's/^.*blastn: //; s/ .*\$//')
    END_VERSIONS
    """

}