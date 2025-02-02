#!/bin/bash

# Run SPAdes assembly on short read paired end data
# see these threads for discussion on --isolate mode:
# https://www.biostars.org/p/9597469/
# https://github.com/ablab/spades/issues/708
# will output results to $OUTDIR (must be located in /staging)

PREFIX="$1"
READ1="$2"
READ2="$3"
OUTDIR="$4"
THREADS="$5"

spades.py -1 $READ1 -2 $READ2 \
-m 240 -t $THREADS \
--careful -k auto \
-o ${OUTDIR}/${PREFIX}