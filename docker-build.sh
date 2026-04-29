#!/usr/bin/env bash

# Exit immediately on error
set -e

# Retry a command up to 5 times with 10 seconds between retries
tryfail() {
    local s=0
    for i in $(seq 1 5); do
        [ $i -gt 1 ] && sleep 10
        "$@" && s=0 && break || s=$?
    done
    return $s
}

# Validate that PKGURL was passed as argument
if [ -z "1" ]; then
    echo "ERROR: Please pass PKGURL as an argument"
    exit 1
fi

# Update package lists
apt-get update

# Install required dependencies
apt-get install -qy --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    openjdk-17-jre-headless \
    procps \
    libcap2-bin \
    tzdata

# Add Ubiquiti apt repository
echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' \
    | tee /etc/apt/sources.list.d/100-ubnt-unifi.list

# Add Ubiquiti GPG key using modern method (apt-key is deprecated)
mkdir -p /etc/apt/trusted.gpg.d
tryfail curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x06E85760C0A52C50" \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/ubiquiti.gpg

# Run architecture-specific pre-build scripts if present
if [ -d "/usr/local/docker/pre_build/$(dpkg --print-architecture)" ]; then
    find "/usr/local/docker/pre_build/$(dpkg --print-architecture)" -type f -exec '{}' \;
fi

# Download and install the UniFi package
curl -fsSL -o ./unifi.deb "${1}"
apt -qy install ./unifi.deb
rm -f ./unifi.deb

# Set correct ownership
chown -R unifi:unifi /usr/lib/unifi

# Clean up apt cache
rm -rf /var/lib/apt/lists/*

# Set up data directories and symlinks
rm -rf ${ODATADIR} ${OLOGDIR} ${ORUNDIR} ${BASEDIR}/data ${BASEDIR}/run ${BASEDIR}/logs
mkdir -p ${DATADIR} ${LOGDIR} ${RUNDIR}
ln -s ${DATADIR} ${BASEDIR}/data
ln -s ${RUNDIR} ${BASEDIR}/run
ln -s ${LOGDIR} ${BASEDIR}/logs
ln -s ${DATADIR} ${ODATADIR}
ln -s ${LOGDIR} ${OLOGDIR}
ln -s ${RUNDIR} ${ORUNDIR}
mkdir -p /var/cert ${CERTDIR}
ln -s ${CERTDIR} /var/cert/unifi

# Remove this build script after use
rm -rf "${0}"
