process SUMMARY_REPORT {
    //tag "$meta.id"    

    conda (params.enable_conda ? "conda-forge::python=3.9.5 conda-forge::pandas=1.3.5 conda-forge::biopython" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.81' :
        'quay.io/biocontainers/biopython' }"

    input:
    path(blast_formatted)
    
    output:
    path ('*.csv')       , emit: report
    path "versions.yml", emit:versions

    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args = task.ext.args ?: ''
    def inputdir = "${projectDir}/${params.outdir}/blast_reformat/"
    def tempdir = "temp_csv"
    // println(blast_formatted)

    // Move CSV files to the temp directory
    """
    mkdir -p $tempdir
    for file in ${blast_formatted}; do
        echo "Moving \$file to $tempdir"
        mv \$file $tempdir
    done
    blastreport.py \\
        -inputfolder $tempdir \\
        -outfolder ./
        $args
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}