#!/bin/bash

#$ -q all.q
#$ -N mlst_blast
#$ -o blast.out
#$ -e blast.err
#$ -pe smp 1-5
#$ -l h_rt=62:00:00
#$ -l h_vmem=120G
#$ -cwd
#$ -V

module load miniconda/24.11.1
source activate nextflow

nextflow run main.nf \
-profile conda,singularity \
--input fasta_samplesheet.csv \
--reference_input reference_input1.csv \
--consensus test_reference_Genome.fasta \
--pid 75 \
--outdir test_out