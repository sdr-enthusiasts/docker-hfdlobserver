FROM ghcr.io/sdr-enthusiasts/docker-baseimage:acars-decoder-soapy

# ENV \

ARG HFDLOBSERVER_VERSION=v0.1.4

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
    # if we are on trixie, we want libglib2.0-0t64, otherwise we want libglib2.0-0
    . /etc/os-release && \
    # distro="$ID" && \
    # version="$VERSION_ID" && \
    codename="$VERSION_CODENAME" && \
    if [[ "$codename" == "bookworm" ]]; then \
    KEPT_PACKAGES+=(libglib2.0-0); \
    else \
    KEPT_PACKAGES+=(libglib2.0-0t64); \
    fi && \
    TEMP_PACKAGES+=(libconfig++-dev) && \
    KEPT_PACKAGES+=(libliquid-dev) && \
    TEMP_PACKAGES+=(libfftw3-dev) && \
    KEPT_PACKAGES+=(libfftw3-bin) && \
    TEMP_PACKAGES+=(zlib1g-dev) && \
    KEPT_PACKAGES+=(zlib1g) && \
    TEMP_PACKAGES+=(libxml2-dev) && \
    TEMP_PACKAGES+=(libjansson-dev) && \
    KEPT_PACKAGES+=(libjansson4) && \
    KEPT_PACKAGES+=(python3-minimal) && \
    KEPT_PACKAGES+=(python3-venv) && \
    TEMP_PACKAGES+=(python3-pip) && \
    TEMP_PACKAGES+=(python3-dev) && \
    KEPT_PACKAGES+=(whiptail) && \
    # install packages
    apt-get update && \
    # Runtime library packages are renamed with Debian releases (soname bumps), so
    # resolve the one each -dev package depends on instead of naming a version.
    runtime_pkg() { \
    p="$(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances "$1" | sed -nE "s/^ *Depends: ($2)\$/\1/p" | head -n1)"; \
    if [ -z "$p" ]; then echo "no runtime package matching $2 for $1" >&2; return 1; fi; \
    echo "$p"; \
    } && \
    KEPT_PACKAGES+=("$(runtime_pkg libconfig++-dev 'libconfig\+\+[0-9]+')") && \
    KEPT_PACKAGES+=("$(runtime_pkg libxml2-dev 'libxml2(-[0-9]+)?')") && \
    apt-get install -y --no-install-recommends \
    "${KEPT_PACKAGES[@]}" \
    "${TEMP_PACKAGES[@]}"\
    && \
    # Install statsd-c-client library. dumphfdl only enables statsd support
    # when it can find this library installed on the system.
    git clone --depth=1 https://github.com/romanbsd/statsd-c-client.git /src/statsd-client && \
    pushd /src/statsd-client && \
    make -j "$(nproc)" && \
    make install && \
    ldconfig && \
    popd && \
    # Install hfdlobserver. The package build compiles its own dumphfdl and
    # bundles kiwiclient.
    mkdir -p /opt/hfdlobserver && \
    python3 -m venv /opt/hfdlobserver/venv && \
    /opt/hfdlobserver/venv/bin/python3 -m pip install --no-cache-dir --no-binary hfdlobserver \
    "git+https://codeberg.org/hfdl-observer/hfdlobserver@${HFDLOBSERVER_VERSION}" && \
    # Clean up
    apt-get remove -y "${TEMP_PACKAGES[@]}" && \
    apt-get autoremove -y && \
    { find /opt/hfdlobserver/venv | grep -E "/__pycache__$" | xargs rm -rf || true; } && \
    bash /scripts/clean-build.sh && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/*


COPY rootfs/ /
