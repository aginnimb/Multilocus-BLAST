process RUN_BLASTN {
    // tag "$meta.id"
    label 'process_medium'

    
    input:
    path(fasta), path(db_dir)
    // tuple val(meta2), path(db)

    output:
    tuple val(meta), path('*.csv'),  emit: blastn_results
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    // def prefix = task.ext.prefix ?: "${meta.id}"
    def db_prefix = task.ext.prefix ?: "${meta2}"

    
    """
    module load miniconda3
    conda activate py-blast

    echo "Running BLAST for sample: \$fasta against database in folder: \$db"

    run_blast.py \\
        -query_file $fasta \\
        -db_folder ${db_prefix}/ \\
        -output_folder ./

    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}