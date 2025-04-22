# Docker dumphfdl

![Banner](https://github.com/sdr-enthusiasts/docker-acarshub/blob/16ab3757986deb7c93c08f5c7e3752f54a19629c/Logo-Sources/ACARS%20Hub.png "banner")
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/sdr-enthusiasts/docker-dumphfdl/deploy.yml?branch=main)](https://github.com/sdr-enthusiasts/docker-dumphfdl/actions?query=workflow%3ADeploy)
[![Docker Pulls](https://img.shields.io/docker/pulls/fredclausen/acarshub.svg)](https://hub.docker.com/r/fredclausen/acarshub)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/fredclausen/acarshub/latest)](https://hub.docker.com/r/fredclausen/acarshub)
[![Discord](https://img.shields.io/discord/734090820684349521)](https://discord.gg/sTf9uYF)

Docker container for running [dumphfdl](https://github.com/szpajder/dumphfdl) and forwarding the received JSON messages to another system or docker container. Best used alongside [ACARS Hub](https://github.com/fredclausen/acarshub).

Builds and runs on `amd64`, `arm64` architectures.

Please note: **DUE TO LIBSDRPLAY, ARMV7 IS NOT SUPPORTED.**

## Required hardware

A computer host on a suitable architecture and one USB RTL-SDR dongle connected to an antenna.

## ACARS Hub integration

The configuration below will enable integration with `acars_router`, which should be configured to forward messages to `acarshub`.

## Up and running

```yaml
version: "2.0"

services:
  dumphfdl:
    image: ghcr.io/sdr-enthusiasts/docker-dumphfdl:latest
    container_name: dumphfdl
    restart: always
    device_cgroup_rules:
      - "c 189:* rwm"
    environment:
      - TZ=${FEEDER_TZ}
      - SOAPYSDRDRIVER=driver=airspyhf,serial=0x3b52aa80389e25ad
      - GAIN_TYPE=--gain
      - SOAPYSAMPLERATE=768000
      - FEED_ID=CS-KABQ-HFDL
      - ZMQ_MODE=server
      - ZMQ_ENDPOINT=tcp://0.0.0.0:45555
      - SERVER=
    tmpfs:
      - /run:exec,size=64M
      - /var/log
      - /tmp
    volumes:
      - /dev:/dev:ro
      - /opt/adsb/data/dumphfdl-data:/opt/dumphfdl
      - /opt/adsb/data/dumphfdl-scanner:/opt/scanner
```

## Supported SDRs

Any device that can be run via SoapySDR with the following drivers should, in theory, work:

- `airspyhf`
- `airspy`
- `rtlsdr` (note....v3 dongles will need an upconverter, and v4 dongles work but are not optimal for HF)
- `SDRPlay`

Keep in mind not every SDR is usable with HF decoding. If you have an SDR that is supported in Soapy, and not listed above, please contact me on discord and I'll see about adding support.

### SDR Play Notes

Please be sure you are in compliance with the license restrictions. The container includes a copy of the license.

You will need SDRPlay installed on the host machine. See [here](https://www.sdrplay.com/downloads/) for more information.

## Configuration options

| Variable                  | Description                                                                                                                                                                                                                                                                                                                            | Required | Default |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- |
| `TZ`                      | Your timezone                                                                                                                                                                                                                                                                                                                          | No       | UTC     |
| `SOAPYSDRDRIVER`          | SoapySDR driver. Required! Should be in the format that you would use to pass in to soapysdr. See the compose example above.                                                                                                                                                                                                           | Yes      | `unset` |
| `GAIN_TYPE`               | The type of gain to use. Can be `--gain` or `--gain-elements`.                                                                                                                                                                                                                                                                         | Yes      | `unset` |
| `GAIN`                    | The gain to use. If used with `GAIN_TYPE=--gain-elements` then this should be in the format your SDR expects. For Airspy style devices something like `IFGR=53,RFGR=2`. Otherwise, if used with `GAIN_TYPE=--gain` then it should be a single value representing a gain value your SDR supports. Example above in the compose section. | Yes      | `unset` |
| `SOAPYSAMPLERATE`         | The sample rate to use. The sample rate that your SDR would expect.                                                                                                                                                                                                                                                                    | Yes      | `unset` |
| `FEED_ID`                 | The feed ID to use. This is the ID that will be used to identify your feed on the ACARS Hub and any site, such as [airframes](airframes.io) that you feed.                                                                                                                                                                             | Yes      | `unset` |
| `ZMQ_MODE`                | The ZMQ mode to use. Can be `server` or `client`.                                                                                                                                                                                                                                                                                      | Yes      | `unset` |
| `ZMQ_ENDPOINT`            | The ZMQ endpoint to use. If `ZMQ_MODE=server` then this should be the endpoint that `acars_router` and other consumers will connect to. If `ZMQ_MODE=client` then this should be the endpoint that a ZMQ server is listening on and expects data from.                                                                                 | Yes      | `unset` |
| `SERVER`                  | If you want this container to forward JSON data, via TCP, to a consumer then set this to the IP address of a consumer                                                                                                                                                                                                                  | No       | `unset` |
| `SERVER_PORT`             | If you want this container to forward JSON data, via TCP, to a consumer then set this to the port of a consumer                                                                                                                                                                                                                        | No       | `unset` |
| `TIMEOUT`                 | The number of seconds that the frequency selector will run each group of frequencies for to pick the optimal HFDL frequencies for monitoring.                                                                                                                                                                                          | No       | `90`    |
| `MIN_MESSAGE_THRESHOLD`   | The minimum number of messages that should be received, on average, during the rolling 30 minute time period. If the average is below this threshold the frequency selector will be re-run.                                                                                                                                            | No       | `5`     |
| `DUMP_HFDL_COMMAND_EXTRA` | Any extra command line parameters to pass to `dumphfdl`, such as extra outputs you would like.                                                                                                                                                                                                                                         | No       | `unset` |
| `ENABLE_SYSTABLE`         | Enrich messages with information about ground stations from the system table. If you want to persist changes that dumphfdl detects, map `/opt/dumphfdl-data` to a volume.                                                                                                                                                              | No       | `true`  |
| `ENABLE_BASESTATION`      | Enrich messages with information about aircraft from basestation database.                                                                                                                                                                                                                                                             | No       | `true`  |
| `BASESTATION_VERBOSE`     | Enable verbose mode for basestation database information.                                                                                                                                                                                                                                                                              | No       | `true`  |
| `FREQUENCIES`             | A list of frequencies to monitor. If this is set, the frequency scanner will not be used.                                                                                                                                                                                                                                              | No       | `unset` |

## What this thing does under the hood, or why don't I have to specify frequencies?

By default, rather than specify frequencies to monitor, the container is set up to use a modified version of the `hfdl.sh` frequency selector script from [wiedehopf](https://raw.githubusercontent.com/wiedehopf/hfdlscript/main/hfdl.sh). This will run through a list of frequencies and pick the best ones to monitor. This is done by running through a list of frequencies, monitoring each for a set amount of time (`TIMEOUT`), and then picking the best ones to monitor. On container start it will run through this list and pick the best frequencies to monitor. It will then start monitoring those frequencies.

After the first 30 minutes have elapsed after container start, the container will monitor a rolling 30 minute time span to verify you are still receiving messages. If you are not, it will re-run the frequency selector script and pick new frequencies to monitor. This will continue to happen every 30 minutes.

If you want to change the frequencies that are monitored manually, run

```bash
docker exec -it dumphfdl /reset-dumphfdl.sh
```

If you do not wish to use the frequency selector script, you can specify frequencies to monitor by setting the `FREQUENCIES` variable. This should be a list of frequencies separated by spaces.

## Customize the frequency selector and retain current state between container starts

Map a volume to `/opt/scanner` to retain the current state of the scanner between container starts. This will allow the scanner to pick up where it left off on container restarts without rescanning.

If you want to customize the frequency bands, number of bands, etc, map a volume to `/opt/scanner` and include a file in there named `scanner_freqs.sh.` Please see [this](https://github.com/sdr-enthusiasts/docker-dumphfdl/blob/main/rootfs/opt/hfdl/scanner_freqs.sh) for an example. Please be sure to follow the same formatting.

## Volumes

| Volume               | Description                                                                                                                  |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `/dev`               | This is required to pass through the SDR device.                                                                             |
| `/opt/dumphfdl-data` | This is where the container will store updated systable information                                                          |
| `/opt/scanner`       | This is where the container will store/load the scanner data, such as the current state and any modified scanner band ranges |

## Future optimizations

It would also be ideal to be more circumspect in gain/sample rate based on the frequencies being monitored, which is how the original script from wiedehopf works.

These are things I will be looking into in the future.
