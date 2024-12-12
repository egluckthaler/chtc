#!/bin/bash

# Run full OrthoFinder analysis on FASTA format proteomes with Diamond
# -og: Stop after inferring orthogroups
# -X:  Don't add species names to sequence IDs
# will output results to $FASTA_DIR (must be located in /staging)

PREFIX="$1"
FASTA_DIR="$2"
THREADS="$3"

orthofinder -X -t $THREADS -a $THREADS -n $PREFIX -S diamond -og -f $FASTA_DIR