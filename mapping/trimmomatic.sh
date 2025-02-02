#!/bin/bash

# Run trimmomatic on short read paired end data
# will output results to $OUTDIR (must be located in /staging)

SAMPLEID="$1"
READ1="$2"
READ2="$3"
OUTDIR="$4"
THREADS="$5"

# only trim reads if the trimmed read file does not exist
if [ ! -f "${OUTDIR}/${SAMPLEID}_1.trim.fa.gz" ]; then

	# trim reads using Alice Feurtey's recommended settings 19.09.21
	trimmomatic PE \
	  ${READ1} ${READ2} -threads $THREADS \
	  ${OUTDIR}/${SAMPLEID}_1.trim.fq.gz ${OUTDIR}/${SAMPLEID}_1_unpaired.fq.gz \
	  ${OUTDIR}/${SAMPLEID}_2.trim.fq.gz ${OUTDIR}/${SAMPLEID}_2_unpaired.fq.gz \
	  ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
	  LEADING:15 TRAILING:15 SLIDINGWINDOW:5:15 MINLEN:50
  
	# remove unpaired reads
	rm ${OUTDIR}/${SAMPLEID}_1_unpaired.fq.gz
	rm ${OUTDIR}/${SAMPLEID}_2_unpaired.fq.gz

fi
