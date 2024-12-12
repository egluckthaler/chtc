#!/bin/bash

mashtree_bootstrap.pl --reps 1000 --numcpus 12 /staging/gluckthaler/magory13/kmer/seqs/*.fasta -- --min-depth 0  > magory13_starships_SLRs.dnd
 
cp magory13_starships_SLRs.dnd /staging/gluckthaler/magory13/kmer/
 