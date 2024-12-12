#!/bin/bash

# Run one round of starfish insert with defaults
# will output results to $OUTDIR on a per genome basis (must be located in /staging)

# Rename variables for transparency
# arguments = $(genome) $(separator) $(ome2assembly) $(blastdb) $(captainbed) $(threads) $(outdir)
GENOME="$1"
SEPARATOR="$2"
OME2ASSEMBLY="$3"
BLASTDB="$4"
CAPTAINBED="$5"
THREADS="$6"
OUTDIR="$7"

if [ ! -d "$OUTDIR/${GENOME}" ]; then

	# Prepare output directories
	mkdir $GENOME
	mkdir temp
	
	# Prepare .bed file
	grep -f <(sed 's/$/_/' <(echo $GENOME)) $CAPTAINBED > temp/${GENOME}.bed
	
	# Run starfish insert on mtdb formatted genomes
	starfish insert --threads $THREADS -i tyr -x $GENOME -o ${GENOME}/ \
	--separator $SEPARATOR \
	-b temp/${GENOME}.bed \
	-a ${OME2ASSEMBLY} \
	-d ${BLASTDB} \
	> $GENOME/${GENOME}_insert.log 2>&1
	
	# Prepare output files for transfer
	mv $GENOME $OUTDIR/

else
	echo "${GENOME} starfish insert output exists in directory $OUTDIR/${GENOME}, skipping\n"
fi
