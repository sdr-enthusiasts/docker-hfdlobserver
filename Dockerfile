FROM ghcr.io/sdr-enthusiasts/docker-baseimage:acars-decoder-soapy

# ENV \

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,SC2086,SC2039,SC1091
RUN set -x && \
  TEMP_PACKAGES=() && \
  KEPT_PACKAGES=() && \
  # Required for building multiple packages.
  TEMP_PACKAGES+=(build-essential) && \
  TEMP_PACKAGES+=(pkg-config) && \
  TEMP_PACKAGES+=(cmake) && \
  TEMP_PACKAGES+=(git) && \
  TEMP_PACKAGES+=(automake) && \
  TEMP_PACKAGES+=(autoconf) && \
  TEMP_PACKAGES+=(wget) && \
  # packages for hfdlobserver
  TEMP_PACKAGES+=(libglib2.0-dev) && \
  KEPT_PACKAGES+=(libglib2.0-0) && \
  TEMP_PACKAGES+=(libconfig++-dev) && \
  KEPT_PACKAGES+=(libconfig++9v5) && \
  KEPT_PACKAGES+=(libliquid-dev) && \
  TEMP_PACKAGES+=(libfftw3-dev) && \
  KEPT_PACKAGES+=(libfftw3-bin) && \
  TEMP_PACKAGES+=(zlib1g-dev) && \
  KEPT_PACKAGES+=(zlib1g) && \
  TEMP_PACKAGES+=(libxml2-dev) && \
  KEPT_PACKAGES+=(libxml2) && \
  TEMP_PACKAGES+=(libjansson-dev) && \
  KEPT_PACKAGES+=(libjansson4) && \
  KEPT_PACKAGES+=(python3-minimal) && \
  KEPT_PACKAGES+=(python3-venv) && \
  TEMP_PACKAGES+=(python3-pip) && \
  KEPT_PACKAGES+=(whiptail) && \
  # install packages
  apt-get update && \
  apt-get install -y --no-install-recommends \
  "${KEPT_PACKAGES[@]}" \
  "${TEMP_PACKAGES[@]}"\
  && \
  # Install statsd-c-client library
  git clone https://github.com/romanbsd/statsd-c-client.git /src/statsd-client && \
  pushd /src/statsd-client && \
  make -j "$(nproc)" && \
  make install && \
  ldconfig && \
  popd && \
  # Install dumphfdl
  git clone https://github.com/szpajder/dumphfdl.git /src/dumphfdl && \
  pushd /src/dumphfdl && \
  mkdir -p /src/dumphfdl/build && \
  pushd /src/dumphfdl/build && \
  cmake ../ -DCMAKE_BUILD_TYPE=Release && \
  make && \
  make install && \
  # Install hfdlobserver
  mkdir -p /opt/hfdlobserver && \
  pushd /opt/hfdlobserver && \
  git clone https://github.com/hfdl-observer/hfdlobserver888.git . && \
  git checkout origin/feature/zeroes && \
  mkdir .virtualenvs && \
  python3 -m venv .virtualenvs/hfdlobserver888 && \
  source .virtualenvs/hfdlobserver888/bin/activate && \
  python3 -m pip install --no-cache-dir -r requirements.txt && \
  git clone https://github.com/jks-prv/kiwiclient.git && \
  deactivate && \
  popd && \
  # Clean up
  apt-get remove -y "${TEMP_PACKAGES[@]}" && \
  apt-get autoremove -y && \
  rm -rf /src/* /tmp/* /var/lib/apt/lists/*


COPY rootfs/ /
