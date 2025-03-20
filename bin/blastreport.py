#!/usr/bin/env python3

import csv
import os
import argparse
import collections

def blast_report(inputfolder,outfolder):
    all_rows = []
    headers_written = False
    reportfile=os.path.join(outfolder, "Blast_Report.csv")

    # if not os.path.exists(outfolder):
    #     os.makedirs(outfolder)

    for file in os.listdir(inputfolder):
        if file.endswith('_formatted.csv'):
            filepath = os.path.join(inputfolder,file)

            with open(filepath, newline='') as infile:
                reader = csv.reader(infile)
                headers=next(reader)
                for row in reader:
                    all_rows.append(row)

            if not headers_written:
                with open(reportfile, 'w', newline='') as outfile:
                    writer = csv.writer(outfile)
                    writer.writerow(headers)
                    headers_written=True

            
    with open(reportfile,'a',newline='') as outfile:
       writer = csv.writer(outfile)
       writer.writerows(all_rows) 
    return reportfile

def summary_report(reportfile, outfolder):
    # dict to store sample-wise loci data
    sample_dict = collections.defaultdict(dict)
    sseqid_check_dict = collections.defaultdict(dict)
    summaryfile=os.path.join(outfolder, "Summary_Report.csv")

    # Open the main BLAST report file
    with open(reportfile, 'r', newline='') as infile:
        reader = csv.DictReader(infile)       
        for row in reader:
            sample_id = row['SampleID']
            locus = row['Locus']
            sseqid = row['sseqid']
            sseqid_split = '_'.join(sseqid.split('_')[:3])
            sseqid_sps = '_'.join(sseqid.split('_',2)[:2])
            # print(sseqid_sps)
            if sample_id not in sseqid_check_dict:
                sseqid_check_dict[sample_id] = sseqid_sps
            else:
                if sseqid_check_dict[sample_id] != sseqid_sps:
                    sseqid_split += '*' # Add '*' to the sseqid if there's a difference
            sample_dict[sample_id][locus] = sseqid_split
            # print(sseqid_split)  # Add sseqid for the given sample and locus

    # Get all unique loci (columns) from the collected data
    all_loci = set()
    for loci_data in sample_dict.values():
        all_loci.update(loci_data.keys())
    all_loci = sorted(all_loci)  # Sorting to ensure consistent column order

    # Write the summary report
    with open(summaryfile, 'w', newline='') as outfile:
        writer = csv.writer(outfile)
        # Write the header row (SampleID, Locus columns)
        header = ['SampleID'] + all_loci
        writer.writerow(header)       
        #sample row
        for sample_id, loci_data in sample_dict.items():
            row = [sample_id]  # Start with SampleID
            
            # Add the sseqid for each locus (or leave blank if not found)
            for locus in all_loci:
                row.append(loci_data.get(locus, ''))  # Default to empty string if no match
            writer.writerow(row)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-inputfolder",required=True, help="Formatted blast results in a folder")
    parser.add_argument("-outfolder",required=True, help="REQUIRED: Output folder for Blast report")
    
    args = parser.parse_args()
    inputfolder = args.inputfolder
    outfolder = args.outfolder
    reportfile= blast_report(inputfolder, outfolder)
    summary_report(reportfile, outfolder)

if __name__ == "__main__":
    main()