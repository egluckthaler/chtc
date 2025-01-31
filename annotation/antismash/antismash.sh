#!/bin/bash

# Run antismash v7 with defaults
# will output results to $OUTDIR on a per genome basis (must be located in /staging)

# Rename variables for transparency
# arguments = $(genome) $(assembly) $(gff) $(threads) $(outdir)

# have job exit if any command returns with non-zero exit status (aka failure)
set -e

# Rename variables for transparency
GENOME="$1"
ASSEMBLY="$2"
GFF="$3"
THREADS="$4"
OUTDIR="$5"

# Hardcoded variables
ANTISMASHDB="/staging/groups/gluckthaler_group/databases/antismash"

# replace env-name on the right hand side of this line with the name of your conda environment
# note ANTISMASHTAR must contain the file ENVNAME.tar.gz
ENVNAME=antismash7
ANTISMASHTAR="/staging/groups/gluckthaler_group/conda_envs"

if [ ! -f "$OUTDIR/${GENOME}/${GENOME}.tar.gz" ]; then

# copy the conda tarball
cp "$ANTISMASHTAR/$ENVNAME.tar.gz" .

# if you need the environment directory to be named something other than the environment name, change this line
export ENVDIR=$ENVNAME

# these lines handle setting up the environment; you shouldn't have to modify them
export PATH
mkdir $ENVDIR
tar -xzf $ENVNAME.tar.gz -C $ENVDIR
. $ENVDIR/bin/activate

# Run antismash
antismash \
--databases $ANTISMASHDB \
--cpus $THREADS \
--output-basename test \
--output-dir output/ \
--taxon fungi \
--clusterhmmer \
--tigrfam \
--cc-mibig \
--cb-general \
--genefinding-gff3 $GFF \
$ASSEMBLY

# Prepare output files for transfer
mkdir "$OUTDIR/$GENOME"
mkdir final
rm output/test.*
cat output/*.gbk > final/${GENOME}.gbk
tar -czf ${GENOME}.tar.gz output/
mv ${GENOME}.tar.gz final/
cp final/${GENOME}.tar.gz "$OUTDIR/$GENOME/"
cp final/${GENOME}.gbk "$OUTDIR/$GENOME/"

else
	echo "$OUTDIR/$GENOME/ antismash output exists, skipping\n"
	
fi
