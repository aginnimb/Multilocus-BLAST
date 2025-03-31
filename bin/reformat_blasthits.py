#!/usr/bin/env python3

import os
import argparse
import pandas as pd

def reformat_blastresults(blastfile,outfolder):
    # Extract SampleID from the filename
    # blast_files = [f for f in os.listdir(blastfolder) if f.endswith('_blastfiltered.csv')]
    # for blastfile in blastfolder:
    #     print(blastfile)
    sample_id = os.path.basename(blastfile).split("_")[0]
    # print(sample_id)
    # Load the BLAST results into a DataFrame
    blast_df = pd.read_csv(blastfile, sep=',')
    print(blast_df)
    blast_df.columns = ['qseqid', 'sseqid', 'pident', 'length', 'qcovs', 'qstart', 'qend',
        'sstart', 'send', 'mismatch', 'gaps', 'evalue', 'bitscore','qlen', 'slen','%query_coverage', '%reference_coverage','NCE']
    
    # Extract Locus from sseqid
    Locus= blast_df['sseqid'].apply(lambda x: x.split('_')[-1])
    output_file = os.path.join(outfolder, f"{sample_id}_blastformatted.csv")
    # Insert the SampleID column at the beginning
    blast_df.insert(0, 'SampleID', sample_id.split('_')[0])
    blast_df.insert(1, 'Locus', value=Locus )
    df1 = blast_df.head(1) #select top 3 hits
    # print(blast_df)
    df1.to_csv(output_file, index=False)

    
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-blastfile",required=True, help="Filtered/Unfiltered blast results in a folder")
    parser.add_argument("-output",required=True, help="REQUIRED: Output folder for reformatted Blast results")
    
    args = parser.parse_args()
    blastfile = args.blastfile
    outfolder = args.output
    reformat_blastresults(blastfile,outfolder)

# Save the final dataframe to a new file
if __name__ == '__main__':
	main()
