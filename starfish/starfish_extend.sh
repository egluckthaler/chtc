#!/bin/bash

# Run one round of starfish extend with defaults
# will output results to $OUTDIR on a per genome basis (must be located in /staging)

# Rename variables for transparency
# arguments = $(genome) $(ome2assembly) $(elementbed) $(naves) $(unaffiliatedcaps) $(outdir)

# Rename variables for transparency
GENOME="$1"
OME2ASSEMBLY="$2"
ELEMENTBED="$3"
NAVES="$4"
UNAFFILIATEDCAPS="$5"
OUTDIR="$6"

if [ ! -d "$OUTDIR/${GENOME}" ]; then

	# Prepare output directories
	mkdir $GENOME
	mkdir temp
	
	# Prepare .bed file per genome
	grep -f <(sed 's/$/_/' <(echo $GENOME)) ${UNAFFILIATEDCAPS} > temp/${GENOME}.bed
	
	# Run starfish extend 
	starfish extend -a ${ASSEMBLIES} \
	-q ${ELEMENTBED} \
	-g ${NAVES} \
	-t temp/${GENOME}.bed \
	-o ${GENOME}/ \
	-i tyr \
	-x magory13 \
	> $GENOME/${GENOME}_extend.log 2>&1
	
	# Prepare output files for transfer
	mv $GENOME $OUTDIR/

else
	echo "${GENOME} starfish extend output exists in $OUTDIR/${GENOME}, skipping\n"
	
fi
