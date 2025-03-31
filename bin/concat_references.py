#!/usr/bin/env python3

import csv
import os
from Bio import SeqIO
import argparse
from Bio.SeqIO import FastaIO

def concatenate_fasta(input_csv, output_fasta):
    # Read the CSV file
    with open(input_csv, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        gene_files = [(row['geneid'], row['reference_fasta']) for row in reader]

    if len(gene_files) == 1:
        # If there's only one gene, copy the file to the output
        os.system(f'cp {gene_files[0][1]} {output_fasta}')
    else:
        # If there are multiple genes, concatenate them into one output file
        with open(output_fasta, 'w') as outfile:
            fasta_writer = FastaIO.FastaWriter(outfile)
            fasta_writer.write_header()
            for geneid, fasta_path in gene_files:
                with open(fasta_path, 'r') as infile:
                    for record in SeqIO.parse(infile, 'fasta'):
                        # Adjust the record id to include the geneid for clarity
                        record.id = f'{geneid}_{record.id}'
                        record.description = ''
                        SeqIO.write(record, outfile, 'fasta')
def main():
    parser = argparse.ArgumentParser(description='Concatenate or copy FASTA files based on a CSV input.')
    parser.add_argument('-input_csv', help='Path to the input CSV file.')
    parser.add_argument('-output_fasta', help='Path to the output FASTA file.')
    args=parser.parse_args()
    concatenate_fasta(args.input_csv, args.output_fasta)

if __name__ == "__main__":
    main()
