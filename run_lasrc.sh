#!/bin/bash

set -e

if [ $1 == "--help" ]; then
    echo "Usage: run_lasrc.sh MTL_FILE"
    exit 0
fi

WORKDIR=/tmp/work
INDIR=/mnt/input-dir
SCENE_ID=$(basename $1 _MTL.txt)
OUTDIR=/mnt/output-dir

for f in $INDIR/*.tif $1; do
    ln -s $f $WORKDIR/$(basename $f)
done

mkdir -p $WORKDIR
cd $WORKDIR

convert_lpgs_to_espa --mtl=${SCENE_ID}_MTL.txt
do_lasrc.py --xml ${SCENE_ID}.xml --write-toa
cloud_masking.py --xml ${SCENE_ID}.xml
convert_espa_to_gtif --xml=${SCENE_ID}.xml --gtif=$SCENE_ID

for f in $WORKDIR/${SCENE_ID}_toa_*.tif $WORKDIR/${SCENE_ID}_sr_*.tif $WORKDIR/${SCENE_ID}_radsat_qa.tif $WORKDIR/${SCENE_ID}_cfmask*.tif; do
    mv $f $OUTDIR
done