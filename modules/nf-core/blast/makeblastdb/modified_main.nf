process BLAST_MAKEBLASTDB {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/blast:2.15.0--pl5321h6f7f691_1':
        'biocontainers/blast:2.15.0--pl5321h6f7f691_1' }"

    input:
    tuple val(meta), path(fasta_files)

    output:
    tuple val(meta), path("${meta.id}"), emit: db
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // def is_compressed = fasta.getExtension() == "gz" ? true : false
    // def fasta_name = is_compressed ? fasta.getBaseName() : fasta
    def fasta_names = fasta_files.collect { file -> 
        def is_compressed = file.getExtension() == "gz" ? true : false
        def base_name = is_compressed ? file.getBaseName() : file
        if (is_compressed) {
            """
            gzip -c -d ${file} > ${base_name}
            """
        } else {
            """
            cp ${file} ${base_name}
            """
        }
        return base_name
    }

    def fasta_input = fasta_names.join(' ')
    """
    #if [ "${is_compressed}" == "true" ]; then
    #    gzip -c -d ${fasta} > ${fasta_name}
    #fi

    makeblastdb \\
        -in ${fasta_input} \\
        ${args}
    mkdir ${prefix}
    mv ${fasta_names.join(' ')}* ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        blast: \$(blastn -version 2>&1 | sed 's/^.*blastn: //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // def is_compressed = fasta.getExtension() == "gz" ? true : false
    // def fasta_name = is_compressed ? fasta.getBaseName() : fasta
    def fasta_names = fasta_files.collect { file -> file.getBaseName() }
    """
    ${fasta_names.collect { name -> "touch ${name}.fasta" }.join('\n')}
    ${fasta_names.collect { name -> "touch ${name}.fasta.ndb" }.join('\n')}
    ${fasta_names.collect { name -> "touch ${name}.fasta.nhr" }.join('\n')}
    ${fasta_names.collect { name -> "touch ${name}.fasta.nin" }.join('\n')}
    ${fasta_names.collect { name -> "touch ${name}.fasta.njs" }.join('\n')}
    ${fasta_names.collect { name -> "touch ${name}.fasta.not" }.join('\n')}
    ${fasta_names.collect { name -> "touch ${name}.fasta.nsq" }.join('\n')}
    ${fasta_names.collect { name -> "touch ${name}.fasta.ntf" }.join('\n')}
    ${fasta_names.collect { name -> "touch ${name}.fasta.nto" }.join('\n')}
    mkdir ${prefix}
    mv ${fasta_names.join(' ')}* ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        blast: \$(blastn -version 2>&1 | sed 's/^.*blastn: //; s/ .*\$//')
    END_VERSIONS
    """
}
