#!/bin/bash

set -e
shopt -s nullglob

if [ $1 == "--help" ]; then
    echo "Usage: run_lasrc.sh SCENE_ID"
    exit 0
fi

SCENE_ID=$1
WORKDIR=/tmp/work
INDIR=/mnt/input-dir
OUTDIR=/mnt/output-dir
MTD_FILES="${SCENE_ID}_MTL.txt ${SCENE_ID}_ANG.txt"
TIF_PATTERNS="$INDIR/${SCENE_ID}_*.tif $INDIR/${SCENE_ID}_*.TIF"

# ensure that workdir is clean
rm -rf $WORKDIR
mkdir -p $WORKDIR
cd $WORKDIR

# only make files with the correct scene ID visible
for f in $TIF_PATTERNS; do
    if $(gdalinfo $f | grep -o 'Block=.*x1\s'); then
        ln -s $f $WORKDIR/$(basename $f)
    else
        # convert tiled tifs to striped layout
        gdal_translate -co TILED=NO $f $WORKDIR/$(basename $f)
    fi
done

for f in $MTD_FILES; do
    cp $INDIR/$f $WORKDIR
done

# run ESPA stack
convert_lpgs_to_espa --mtl=${SCENE_ID}_MTL.txt
do_lasrc.py --xml ${SCENE_ID}.xml --write_toa
cloud_masking.py --xml ${SCENE_ID}.xml
convert_espa_to_gtif --xml=${SCENE_ID}.xml --gtif=$SCENE_ID --del_src_files

# copy outputs from workdir
OUT_PATTERNS="$WORKDIR/${SCENE_ID}_toa_*.tif $WORKDIR/${SCENE_ID}_sr_*.tif $WORKDIR/${SCENE_ID}_radsat_qa.tif $WORKDIR/${SCENE_ID}_cfmask*.tif"
for f in $OUT_PATTERNS; do
    cp $f $OUTDIR
done

for f in $MTD_FILES; do
    cp $WORKDIR/$f $OUTDIR
done

rm -rf $WORKDIR