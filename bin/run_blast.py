#!/usr/bin/env python3

import os 
import subprocess 
import argparse

def run_blast(query_file, db_folder, output_folder): 
    # List all database files in the folder 
    db_files = [f for f in os.listdir(db_folder) if f.endswith('.nin')]
    print(f"Database files found: {db_files}")
    if not db_files:
        print(f"No database files found in {db_folder}")
        return

    for db_file in db_files: 
        db_path = os.path.join(db_folder, db_file)
        # print(db_path[:-4])
        query_name=os.path.basename(query_file).split("_")[0]
        db_name=os.path.basename(db_file).split(".")[0]
        output_file = os.path.join(output_folder, f"{query_name}_{db_name}_blast.csv") 
# Execute the command 
        try: 
            subprocess.run(['blastn', '-query', query_file,'-db', db_path,'-out', output_file,'-outfmt', '10 qseqid sseqid pident length qcovs qstart qend sstart send mismatch gaps evalue bitscore qlen slen' ], check=True) 
            print(f"Completed BLAST for {query_file} against {db_file}") 
        except subprocess.CalledProcessError as e: print(f"Error running BLAST: {e}") 


def main():
    parser = argparse.ArgumentParser(description='provide assemblies and blastdb folder perform the blast analysis')
    parser.add_argument('-query_file', help="assembly in fasta format")
    parser.add_argument('-db_folder', help="Blast database in a folder")
    parser.add_argument('-output_folder', help="Output folder to save the results" )

    args=parser.parse_args()
    query_file=args.query_file
    db_folder=args.db_folder
    output_folder=args.output_folder
    run_blast(query_file, db_folder, output_folder)


if __name__ == '__main__':
    main()