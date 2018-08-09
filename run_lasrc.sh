#!/bin/bash

set -e
shopt -s nullglob

if [ $1 == "--help" ]; then
    echo "Usage: run_lasrc.sh MTL_FILE"
    exit 0
fi

WORKDIR=/tmp/work
INDIR=/mnt/input-dir
SCENE_ID=$(basename $1 _MTL.txt)
OUTDIR=/mnt/output-dir

# ensure that workdir is clean
rm -rf $WORKDIR
mkdir -p $WORKDIR
cd $WORKDIR

# only make files with the correct scene ID visible
for f in "$INDIR/${SCENE_ID}_*.tif" "$INDIR/${SCENE_ID}_*.TIF"; do
    if $(gdalinfo $f | grep -o 'Block=.*x1\s'); then
        ln -s $f $WORKDIR/$(basename $f)
    else
        # convert tiled tifs to striped layout
        gdal_translate -co TILED=NO $f $WORKDIR/$(basename $f)
    fi
done

cp "$INDIR/${SCENE_ID}_MTL.txt" $WORKDIR

convert_lpgs_to_espa --mtl=${SCENE_ID}_MTL.txt
do_lasrc.py --xml ${SCENE_ID}.xml --write-toa
cloud_masking.py --xml ${SCENE_ID}.xml
convert_espa_to_gtif --xml=${SCENE_ID}.xml --gtif=$SCENE_ID --del_src_files

for f in "$WORKDIR/${SCENE_ID}_toa_*.tif" "$WORKDIR/${SCENE_ID}_sr_*.tif" "$WORKDIR/${SCENE_ID}_radsat_qa.tif" "$WORKDIR/${SCENE_ID}_cfmask*.tif" "$WORKDIR/${SCENE_ID}_MTL.txt"; do
    mv $f $OUTDIR
done

rm -rf $WORKDIR