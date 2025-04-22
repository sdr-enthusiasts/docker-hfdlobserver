# Docker hfdlobserver

![Banner](https://github.com/sdr-enthusiasts/docker-acarshub/blob/16ab3757986deb7c93c08f5c7e3752f54a19629c/Logo-Sources/ACARS%20Hub.png "banner")
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/sdr-enthusiasts/docker-hfdlobserver/deploy.yml?branch=main)](https://github.com/sdr-enthusiasts/docker-hfdlobserver/actions?query=workflow%3ADeploy)
[![Docker Pulls](https://img.shields.io/docker/pulls/fredclausen/acarshub.svg)](https://hub.docker.com/r/fredclausen/acarshub)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/fredclausen/acarshub/latest)](https://hub.docker.com/r/fredclausen/acarshub)
[![Discord](https://img.shields.io/discord/734090820684349521)](https://discord.gg/sTf9uYF)

Docker container for running [hfdlobserver](https://github.com/hfdl-observer/hfdlobserver888) and forwarding the received JSON messages to another system or docker container. Best used alongside [ACARS Hub](https://github.com/fredclausen/acarshub).

Builds and runs on `amd64`, `arm64` architectures.

## Setup

Follow the example docker-compose.yml in this repository. You will need to mount a volume in the container at `/run/hfdlobserver` with a `settings.yaml` file in it. The `compose/settings.yaml` file is a nice starting point. Please uncomment relevant lines and change addresses as appropriate. The file is well commented so work it from top to bottom to get your settings.yaml file.
