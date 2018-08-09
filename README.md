# Lasrclicious
Orchestrate LaSRC atmospheric correction and cloud masking. :lollipop:


## Dependencies

- Docker
- The [LaSRC auxiliary files](http://edclpdsftp.cr.usgs.gov/downloads/auxiliaries/lasrc_auxiliary/lasrc_aux.2013-2017.tar.gz) somewhere on your machine (can be updated through [this script](https://github.com/USGS-EROS/espa-surface-reflectance/blob/master/lasrc/landsat_aux/scripts/updatelads.py) from USGS)


## Voll Laser wie du abgehst!

Build image:

```bash
$ docker build -t lasrc .
```

Do atmospheric correction and cloud masking for the scene 
`LC08_L1TP_192022_20180630_20180630_01_RT`:

```bash
$ docker run \
    -v /path/to/inputs:/mnt/input-dir:ro \
    -v /path/to/outputs:/mnt/output-dir:rw \
    -v /path/to/lasrc-aux:/mnt/lasrc-aux:ro \
    --rm \
    -t lasrc LC08_L1TP_192022_20180630_20180630_01_RT
```