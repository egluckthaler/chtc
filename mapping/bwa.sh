#!/bin/bash

# make a window coverage file of mapped short read data to a reference assembly, from Sam O'Donnell 01/29/2025

# have job exit if any command returns with non-zero exit status (aka failure)
set -e

# note CONDATAR must contain the file ENVNAME.tar.gz
ENVNAME=shortReadMapping
CONDATAR="/staging/groups/gluckthaler_group/conda_envs"

# copy the conda tarball
cp "$CONDATAR/$ENVNAME.tar.gz" .

# if you need the environment directory to be named something other than the environment name, change this line
export ENVDIR=$ENVNAME

# these lines handle setting up the environment; you shouldn't have to modify them
export PATH
mkdir $ENVDIR
tar -xzf $ENVNAME.tar.gz -C $ENVDIR
. $ENVDIR/bin/activate

## set commandline args here
referenceAssembly="$1"
forwardReads="$2"
reverseReads="$3"
sampleID="$4"
threads="$5"
outdir="$6"

referenceID=$(basename ${referenceAssembly})

##windows and slide for calculating coverage (in bp)
window=10000
slide=5000

##reformatting window and slide numbers for directory generation in kb
window2=$( echo $window | awk '{print $0/1000}' )
slide2=$( echo $slide | awk '{print $0/1000}' )

echo "creating mapping indices and window files.."

##make a fai index with samtools
samtools faidx ${referenceAssembly}

##use it to makea reference bed file, 
cat ${referenceAssembly}.fai | cut -f1-2 > ${referenceID}.bed

##now split the reference bed file up into the above prescribed bins
bedtools makewindows -w ${window} -s ${slide} -g ${referenceID}.bed > ${referenceID}.${window2}kbwindow_${slide2}kbslide.bed

##skip this part if sorted bam already exists because it is the most compute intense
if [ ! -f "${outdir}/${sampleID}.bwamem.${referenceID}.sorted.bam" ]; then

echo "mapping reads to reference with bwa-mem2.."

##make a bwa-mem2 index
bwa-mem2 index ${referenceAssembly}

###we will use bwa-mem for mapping and direct the output directly to a sorted bam file
bwa-mem2 mem -t ${threads} ${referenceAssembly} ${forwardReads} ${reverseReads} | samtools sort -@ 6 -o ${outdir}/${sampleID}.bwamem.${referenceID}.sorted.bam -
fi

echo "parsing bam files and calculating coverage"

##calculate some stats for the mapping (paritcularly interested in the reads with paired reads not mapping together)
samtools flagstat -O tsv ${outdir}/${sampleID}.bwamem.${referenceID}.sorted.bam > ${outdir}/${sampleID}.bwamem.${referenceID}.sorted.flagstat.tsv

##calculate the coverage per bam file using bedtools genomecov, using the -ibam option
bedtools genomecov -d -ibam ${outdir}/${sampleID}.bwamem.${referenceID}.sorted.bam | gzip > ${sampleID}.bwamem.${referenceID}.cov.tsv.gz

##calculate genome wide median
median=$( zcat ${sampleID}.bwamem.${referenceID}.cov.tsv.gz | awk '{if($3 != "0") print $3}' | sort -n | awk '{ a[i++]=$1} END{x=int((i+1)/2); if(x < (i+1)/2) print (a[x-1]+a[x])/2; else print a[x-1];}' )

##generate another file with the genome wide median coverage normalised coverage in the last column
zcat ${sampleID}.bwamem.${referenceID}.cov.tsv.gz | awk -v median="$median" '{print $0"\t"$3/median}' | gzip > ${outdir}/${sampleID}.bwamem.${referenceID}.cov.medianNORM.tsv.gz

##get the coverage file (slightly modify by giving a range for the single basepair coverage value) then use bedtools map to overlap with the referenceID derived window file to create median-averaged bins
zcat ${sampleID}.bwamem.${referenceID}.cov.tsv.gz | awk '{print $1"\t"$2"\t"$2"\t"$3}' |\
bedtools map -b - -a ${referenceID}.${window2}kbwindow_${slide2}kbslide.bed -c 4 -o median | awk -v median="$median" '{print $0"\t"$4/median}' > ${outdir}/${sampleID}.bwamem.${referenceID}.cov.medianNORM.${window2}kbwindow_${slide2}kbsliding.tsv
