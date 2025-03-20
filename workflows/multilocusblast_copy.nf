// valid_genomes = ['18s','actin','hsp70','BG','GDH','TPI']
// params.selected_genomes = (params.valid_genomes ?: 'all').split(',')
// params.reference_fastas = (params.reference_fastas ?: params.reference_fastas.split(','))

if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FASTQC                 } from '../modules/nf-core/fastqc/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-validation'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_multilocusblast_pipeline'
include { BLAST_MAKEBLASTDB         } from '../modules/nf-core/blast/makeblastdb/main'
include { QUAST                     } from '../modules/nf-core/quast/main'
include { BLAST_BLASTN              } from '../modules/nf-core/blast/blastn/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT SUBWORKFLOWS 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { SAMPLESHEET_CHECK                      } from '../modules/local/samplesheet_check.nf'
include { INPUT_CHECK                           } from '../modules/local/inputcheck.nf'
include { PARSE_BLAST_RESULTS                   } from '../modules/local/parse_Blast.nf'
include { CONCATENATE_REFERENCES                } from '../modules/local/concatenate_refs.nf'
/*'
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow MULTILOCUSBLAST {

    take:
    ch_samplesheet // channel: samplesheet read in from --input

    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()
    // ch_assemblies = Channel.empty()
    ch_blastresults = Channel.empty()
    ch_referencesheet = Channel.empty()
    ch_consensus = Channel.empty()

    // Channel
    //     .fromPath("$params.assemblies/*.fasta", checkIfExists: true)
    //     .map { file -> 
    //         def tuple = tuple(file.simpleName, file) 
    //         //println tuple
    //         return tuple
    //     }
    //     .set{ ch_assemblies }
        // println(ch_assemblies)

    // Channel
    //     .fromPath("$params.consensus", checkIfExists: true)
    //     .map { row -> 
    //         def id = row.simpleName - ".fasta"
    //         def tuple = tuple(id, row) 
    //         // println "Tuple: ${tuple}"
    //         return tuple
    //     }
    //     .set{ ch_consensus }
        
    Channel
        .fromPath("${params.reference_input}")
        .splitCsv(header: true)
        .map { row ->
           tuple ( row.geneid, reference_fasta)
            // return [meta,reference_fasta]
        }
        .set { ch_referencesheet }

    // Channel
    //     .fromPath("${params.reference_input}")
    //     .splitCsv(header: true)
    //     .map { row ->
    //         // def meta = [:]
    //         meta.id = row.geneid
    //         def reference_fasta = [meta, file(row.reference_fasta)]
    //         return [meta,reference_fasta]
    //     }
    //     .set { ch_referencesheet }

    //
    // MODULE: Run FastQC
    //
    // FASTQC (
    //     ch_samplesheet
    // )
    // ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})
    // ch_versions = ch_versions.mix(FASTQC.out.versions.first())

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(storeDir: "${params.outdir}/pipeline_info", name: 'nf_core_pipeline_software_mqc_versions.yml', sort: true, newLine: true)
        .set { ch_collated_versions }

    //
    // MODULE: MultiQC
    //
    ch_multiqc_config                     = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config              = params.multiqc_config ? Channel.fromPath(params.multiqc_config, checkIfExists: true) : Channel.empty()
    ch_multiqc_logo                       = params.multiqc_logo ? Channel.fromPath(params.multiqc_logo, checkIfExists: true) : Channel.empty()
    summary_params                        = paramsSummaryMap(workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary                   = Channel.value(paramsSummaryMultiqc(summary_params))
    ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = Channel.value(methodsDescriptionText(ch_multiqc_custom_methods_description))
    ch_multiqc_files                      = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files                      = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files                      = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml', sort: false))

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList()
    )


    // SAMPLESHEET_CHECK("${params.reference_input}")
    //     .out
    //     .csv
    //     .map { row ->
    //         def meta = [:] 
    //         meta.id= row.geneid
    //         def ref_fasta = [meta, file(row.reference_fasta)]
    //         return ref_fasta
    //     }  
    //     .set {ch_referencesheet}

    // ch_referencesheet.view()

    //INPUT_CHECK()
    // ch_assemblies = INPUT_CHECK.out.fasta_files

    // if (params.selected_genomes.contains('all')) {
    //     selected_genomes = params.valid_genomes
    // } else {
    //     selected_genomes = params.selected_genomes.intersect(params.valid_genomes)
    // }

    // //channel to map genome name to fasta files
    // fasta_map = Channel.fromFilePairs(params.reference_fastas, flat: true)
    //     .filter { genome, path -> selected_genomes.contains(genome) }
    //     .groupTuple()

    // fasta_map
    //     .map { genome, fasta_paths -> tuple([id: genome], fasta_paths) }
    //     .set { selected_genomes_fasta }
    
    // selected_genomes_fasta.into {blast_input}

    // CONCATENATE_REFERENCES(ch_referencesheet)
    BLAST_MAKEBLASTDB(ch_referencesheet)
    // BLAST_MAKEBLASTDB(CONCATENATE_REFERENCES.out.concatenated_fasta)
    //BLAST_MAKEBLASTDB("${params.reference_fastas}")
    // params.reference_fastas.view()
    // ch_samplesheet.view()
    // QUAST(ch_samplesheet,"${params.consensus}")
    //BLAST_BLASTN(ch_assemblies,BLAST_MAKEBLASTDB.out.db)

    // ch_blastresults = Channel.empty()

    // BLAST_BLASTN
    //     .out
    //     .blastn_results
    //     .map{ file ->tuple (file.simpleName, file) }
    //     .set{ ch_blastresults }

    // PARSE_BLAST_RESULTS(ch_blastresults, "${params.pid}")
    


    emit:
    multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
