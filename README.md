# Lasrclicious
Orchestrate LaSRC atmospheric correction and cloud masking. :lollipop:

## Voll Laser wie du abgehst!

Build image:

```bash
$ docker build -t lasrc .
```

Do atmospheric correction and cloud masking:

```bash
$ docker run -v /path/to/inputs:/mnt/input-dir -v /path/to/outputs:/mnt/output-dir -v /path/to/lasrc-aux:/mnt/lasrc-aux -t lasrc LC08_L1TP_192022_20180630_20180630_01_RT_MTL.txt
```