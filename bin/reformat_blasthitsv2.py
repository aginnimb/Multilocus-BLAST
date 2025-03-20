#!/usr/bin/env python3

import csv
import os
import argparse

def reformat_blastresults(blastfile,outfile):
    # Extract SampleID from the filename
    sample_id = os.path.basename(blastfile).split("_")[0]
    basename=blastfile.rsplit('.', 1)[0]
    parts=basename.split('_')
    locus=parts[-2]

    
    # output_file = os.path.join(outfolder, f"{sample_id}_blastformatted.csv")
    
    # Define the column names as done in pandas
    columns = ['qseqid', 'sseqid', 'pident', 'length', 'qcovs', 'qstart', 'qend',
               'sstart', 'send', 'mismatch', 'gaps', 'evalue', 'bitscore', 
               'qlen', 'slen', '%query_coverage', '%reference_coverage', 'NCE']
    
    # Read the BLAST results and process them
    with open(blastfile, newline='') as infile:
        reader = csv.reader(infile)
        # print(infile)
        next(reader)  # Skip the original header since we're defining our own
        
        rows = []
        for row in reader:
            # Match each value to the columns (assuming order is correct)
            blast_data = dict(zip(columns, row))
            sseqid = blast_data['sseqid']
            # locus = sseqid.split('_')[-1]  # Extract Locus from 'sseqid'
            
            # Add SampleID and Locus to the row
            row.insert(0, sample_id)
            row.insert(1, locus)
            
            rows.append(row)
        
    # Add 'SampleID' and 'Locus' to the defined columns
    headers = ['SampleID', 'Locus'] + columns
    
    # Write the processed results to the new CSV
    with open(outfile, 'w', newline='') as outfile:
        writer = csv.writer(outfile)
        
        # Write headers and the top hit
        writer.writerow(headers)
        writer.writerow(rows[0])  # Only the top hit is written

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-blastfile",required=True, help="Filtered/Unfiltered blast results in a folder")
    parser.add_argument("-outfile",required=True, help="REQUIRED: Output file for reformatted Blast results")
    
    args = parser.parse_args()
    blastfile = args.blastfile
    outfile = args.outfile
    reformat_blastresults(blastfile,outfile)

# Save the final dataframe to a new file
if __name__ == '__main__':
	main()