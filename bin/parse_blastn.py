#!/usr/bin/env python3

import csv
import argparse

def parse_blast_results(input_file, pident_threshold, output_file):
    # Define the headers for the output CSV
    headers = ["qseqid", "sseqid", "pident", "length", "qcovs", "qstart", "qend", "sstart", "send", "mismatch", "gaps", "evalue", "bitscore","qlen", "slen" , "%query_coverage","%reference_coverage", "NCE"]

    with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
        reader = csv.reader(infile, delimiter=',')
        writer = csv.writer(outfile)

        # Write the header row to the output file
        writer.writerow(headers)

         # Dictionary to store the best hit if sample is below threshold
        best_below_threshold = {}

        for row in reader:
            try:
                qseqid = str(row[0])
                sseqid = str(row[1])
                pident = float(row[2])
                length = int(row[3])
                qcovs = float(row[4])
                qstart = int(row[5])
                qend = int(row[6])
                sstart = int(row[7])
                send = int(row[8])
                mismatch = int(row[9])
                gaps =  int(row[10])
                evalue = float (row[11])
                bitscore = int(row[12])
                qlen   = int(row[13])
                slen   = int(row[14])
                reference_coverage = length / slen * 100
                query_coverage = (abs(qend - qstart) + 1) / qlen * 100
                # print(query_coverage)

                # if qstart < qend:
                #     aligned_query_length = max(qend - qstart + 1, 0)  # Length of aligned region on query
                # else:
                #     aligned_query_length = max(abs(qstart - qend)+ 1, 0) #indicates the alignment is in reverse direction
                # aligned_subject_length = max(send - sstart + 1, 0)
				# 		# print(aligned_subject_length)

                # if aligned_subject_length != 0:
				# 			# print(aligned_subject_length)
                #     query_coverage = (aligned_query_length / aligned_subject_length) * 100
                # else:
				# 			# print("Aligned_subject_length is Zero!!!!!!")
                #     continue
                # print(row)
                if pident > pident_threshold and query_coverage > 0.75:
                    # print(row)                           
                    writer.writerow(row + [query_coverage,reference_coverage]) # Append the query_coverage to the row and write to the output file
                else:
                    # Check if the sample is already in the dictionary
                    if qseqid not in best_below_threshold or (pident > best_below_threshold[qseqid]['pident'] or query_coverage > best_below_threshold[qseqid]['query_coverage']):
                        # Update the best hit for samples not meeting the threshold
                        best_below_threshold[qseqid] = {
                            'row': row,
                            'pident':pident,
                            'query_coverage': query_coverage,
                            'reference_coverage': reference_coverage
                        }
            except ValueError as e:
                print(f"Skipping row due to value error: {row} - {e}")

        # Write the best hits below the threshold with an "NCE" label
        for qseqid, hit_info in best_below_threshold.items():
            writer.writerow(hit_info['row'] + [hit_info['query_coverage'], hit_info['reference_coverage'], "Sample did not meet the threshold,best hit was added"])

def main():
    parser = argparse.ArgumentParser(description='provide blast report and parameters to filter the blast hits')
    parser.add_argument('-blastreport', help="BLASTn analysis report")
    parser.add_argument('-identity', default ='75', type=float, help="Blast percent identity to filter the hits")
    parser.add_argument('-output', help="Output filename to save the results" )

    args=parser.parse_args()
    input_file = args.blastreport
    output_file =args.output
    pident_threshold=args.identity
    # bitscore_threshold=args.bitscore
    parse_blast_results(input_file,pident_threshold,output_file)

if __name__ == "__main__":
    main()
