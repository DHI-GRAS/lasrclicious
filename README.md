# Lasrclicious
Orchestrate LaSRC atmospheric correction and cloud masking. :lollipop:


## Dependencies

- Docker
- A token from NASA/EarthData for downloading the LADS auxiliary data


## Voll Laser wie du abgehst!

### Build image:

```bash
$ docker build -t lasrc .
```

### Download auxiliary data for 2018

```bash
$ docker run \
    -v /path/to/lasrc-aux:/mnt/lasrc-aux:rw \
    -e LADS_TOKEN="my-lads-token" \
    --rm \
    -t lasrc updatelads -s 2018 -e 2018
```

### Do atmospheric correction and cloud masking for the scene 
`LC08_L1TP_192022_20180630_20180630_01_RT`:

```bash
$ docker run \
    -v /path/to/inputs:/mnt/input-dir:ro \
    -v /path/to/outputs:/mnt/output-dir:rw \
    -v /path/to/lasrc-aux:/mnt/lasrc-aux:ro \
    --rm \
    -t lasrc process LC08_L1TP_192022_20180630_20180630_01_RT
```
