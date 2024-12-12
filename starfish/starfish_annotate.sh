#!/bin/bash

# Run one round of starfish annotate with defaults
# will output results to $OUTDIR on a per genome basis (must be located in /staging)

# Rename variables for transparency
# arguments = $(genome) $(assembly) $(gff) $(idtag) $(separator) $(namefield) $(targetfeat) $(threads) $(outdir)
GENOME="$1"
ASSEMBLY="$2"
GFF="$3"
IDTAG="$4"
SEPARATOR="$5"
NAMEFIELD="$6"
TARGETFEAT="$7"
THREADS="$8"
OUTDIR="$9"

# determine appropriate HMM and PROTEIN files based on idtag
HMM=""
PROTEIN=""
if [[ "$IDTAG" == 'tyr' ]]; then
	HMM="YRsuperfams.p1-512.hmm"
	PROTEIN="YRsuperfamRefs.faa"
elif [[ "$IDTAG" == 'plp' ]]; then
	HMM="plp.hmm"
	PROTEIN="plp.mycoDB.faa"
elif [[ "$IDTAG" == 'fre' ]]; then
	HMM="fre.hmm"
	PROTEIN="fre.mycoDB.faa"
elif [[ "$IDTAG" == 'd37' ]]; then
	HMM="duf3723.hmm"
	PROTEIN="duf3723.mycoDB.faa"
elif [[ "$IDTAG" == 'nlr' ]]; then
	HMM="nlr.hmm"
	PROTEIN="nlr.mycoDB.faa"
elif [[ "$IDTAG" == 'myb' ]]; then
	HMM="myb.hmm"
	PROTEIN="myb.SRG.fa"
else
	echo "WARNING: idtag values must only equal tyr, plp, d37, nlr, fre, or myb"
	exit
fi

if [ ! -d "$OUTDIR/$IDTAG/${GENOME}" ]; then

	# Prepare output directories
	mkdir ${GENOME}_temp
	mkdir $GENOME
	mkdir temp
	
	# Prepare assembly and gff files
	echo -e "$GENOME\t$ASSEMBLY" > ome2assembly.txt
	echo -e "$GENOME\t$GFF" > ome2gff.txt
	
	# Run starfish annotate on mtdb formatted genomes
	starfish annotate --noCheck --separator $SEPARATOR --nameField $NAMEFIELD --targetFeat $TARGETFEAT \
	--assembly ome2assembly.txt --gff ome2gff.txt --tempdir temp --outdir ${GENOME}_temp \
	--prefix ${GENOME}.${IDTAG} -p $HMM -P $PROTEIN --idtag $IDTAG --threads $THREADS \
	> $GENOME/${GENOME}_annotate.log 2>&1
	
	# Prepare output files for transfer
	mv ${GENOME}_temp/*.filt* $GENOME/
	mv ${GENOME}_temp/*annotate.log $GENOME/
	mv $GENOME $OUTDIR/$IDTAG/

else
	echo "${GENOME} starfish annotate output exists in directory $OUTDIR/$IDTAG/${GENOME}, skipping\n"
fi

