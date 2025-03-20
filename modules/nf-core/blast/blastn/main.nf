process BLAST_BLASTN {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/blast:2.15.0--pl5321h6f7f691_1':
        'biocontainers/blast:2.15.0--pl5321h6f7f691_1' }"

    input:
    tuple val(meta), path(fasta),path(db_dir)

    output:
    tuple val(meta), path('*.txt'),  emit: blastn_results
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def db_prefix = db_dir.getBaseName()    
// def is_compressed = fasta.getExtension() == "gz" ? true : false
    // def fasta_name = is_compressed ? fasta.getBaseName() : fasta
        // for DB in \$(find -L ${db} -type f -name "*.ndb" -o -name "*.nin" | sed 's/\\.ndb\$//;s/\\.nin\$//'  | sort -u); do
        // echo Using \$DB
    """
    DB=\$(find -L ${db_dir} -type f -name "*.ndb" -o -name "*.nin" | sed 's/\\.ndb\$//;s/\\.nin\$//' | sort -u)
    if [ -z "\$DB" ]; then
        echo "No valid BLAST database files found in ${db_dir}."
        exit 1
    fi
    
    blastn \\
        -num_threads ${task.cpus} \\
        -db \$DB \\
        -query $fasta  \\
        ${args} \\
        -outfmt '10 qseqid sseqid pident length qcovs qstart qend sstart send mismatch gaps evalue bitscore qlen slen' \\
        -out ./${prefix}_${db_prefix}_blastn.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        blast: \$(blastn -version 2>&1 | sed 's/^.*blastn: //; s/ .*\$//')
    END_VERSIONS
    """

    // stub:
    // def args = task.ext.args ?: ''
    // def prefix = task.ext.prefix ?: "${meta.id}"

}
