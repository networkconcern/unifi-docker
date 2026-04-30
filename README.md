# UniFi Controller in Docker

A Dockerized version of Ubiquiti's UniFi Network Controller, maintained by [Network Concern](https://hub.docker.com/r/networkconcern/unifi).

## Why Use This?

Using Docker, you no longer need to worry about Java versions, OS compatibility, or manual update processes. Everything is packaged into a single, tested container. To install: run one command. To upgrade: swap the container. That's it.

Tested on: **Ubuntu, Debian, macOS, Windows, and Synology NAS (arm64/amd64).**

---

## Current Version

| Tag | Version | Description |
|-----|---------|-------------|
| `latest` | **v10.3.58** | Current stable release (updated 2026-04-30) |
| `master` | **v10.3.58** | Same as latest, built from master branch |

> **To upgrade:** simply update `UNIFI_VERSION` in `build.yml` to the new version and push. The CI pipeline rebuilds and publishes automatically.

---

## Quick Start

### 1. Create the required directories

```bash
mkdir -p ~/unifi/data
mkdir -p ~/unifi/log
mkdir -p ~/unifi/cert
```

### 2. Run the container

```bash
docker run -d --init \
  --restart=unless-stopped \
  -p 8080:8080 \
  -p 8443:8443 \
  -p 3478:3478/udp \
  -e TZ='America/New_York' \
  -v ~/unifi:/unifi \
  --user unifi \
  --name unifi \
  networkconcern/unifi:latest
```

After a minute or two, access the controller at: **https://\<docker-host-ip\>:8443**

> **Note:** Your browser will show an untrusted certificate warning on first access — this is expected. Accept the connection to proceed.

---

## Synology NAS (Docker / Container Manager)

1. Open **Container Manager** on your Synology NAS
2. Go to **Registry** and search for `networkconcern/unifi`
3. Download the `latest` tag
4. Create the container with the port and volume mappings below
5. Or use the provided `docker-compose.yml` file

---

## Docker Compose

```yaml
version: '3'
services:
  unifi:
    image: networkconcern/unifi:latest
    init: true
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "8443:8443"
      - "3478:3478/udp"
      - "8843:8843"
      - "8880:8880"
      - "6789:6789"
    environment:
      - TZ=America/New_York
    volumes:
      - ~/unifi:/unifi
    user: unifi
```

---

## Stopping and Upgrading

### Stop the container
```bash
docker stop unifi
docker rm unifi
```

### Upgrade to a new version
1. **Always make a backup first** (Settings → System → Backup in the UniFi web UI)
2. Stop the current container (see above)
3. Pull the new image: `docker pull networkconcern/unifi:latest`
4. Run the new container with the same `docker run...` command

---

## Ports

| Port | Protocol | Required | Description |
|------|----------|----------|-------------|
| 8080 | TCP | ✅ Yes | Device communication |
| 8443 | TCP | ✅ Yes | Web interface + API (HTTPS) |
| 3478 | UDP | ✅ Yes | STUN service |
| 8843 | TCP | Optional | HTTPS captive portal |
| 8880 | TCP | Optional | HTTP captive portal |
| 6789 | TCP | Optional | UniFi Speed Test |
| 10001 | UDP | Optional | Device discovery |

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | — | Timezone (e.g. `America/New_York`) |
| `UNIFI_HTTP_PORT` | 8080 | HTTP port for web interface |
| `UNIFI_HTTPS_PORT` | 8443 | HTTPS port for web interface |
| `PORTAL_HTTP_PORT` | 8880 | HTTP portal redirect port |
| `PORTAL_HTTPS_PORT` | 8843 | HTTPS portal redirect port |
| `UNIFI_STDOUT` | unset | Output logs to stdout |
| `JVM_MAX_HEAP_SIZE` | 1024M | Max JVM heap memory |
| `JVM_INIT_HEAP_SIZE` | unset | Initial JVM heap size |
| `JVM_EXTRA_OPTS` | unset | Additional JVM arguments |
| `LOTSOFDEVICES` | unset | Set `true` for optimized performance on large networks or low-power devices |
| `CERT_IS_CHAIN` | false | Set `true` if your SSL cert is already a full chain |
| `UNIFI_ECC_CERT` | unset | Set `true` if using Elliptic Curve SSL certificates |

---

## Volumes

| Path (inside container) | Description |
|------------------------|-------------|
| `/unifi/data` | UniFi configuration and database |
| `/unifi/log` | Log files |
| `/unifi/cert` | Custom SSL certificates |
| `/unifi/init.d` | Scripts executed on container startup |
| `/var/run/unifi` | Runtime PID files |

---

## Adopting UniFi Devices

For your UniFi access points and devices to find the controller running in Docker, you **must** set the Inform Host IP:

1. In the UniFi web UI go to: **Settings → System → Other Configuration → Override Inform Host**
2. Enable the option and enter the **IP address of your Docker host**
3. Save and restart the container

---

## Custom SSL Certificates

Place your certificates in the volume mapped to `/unifi/cert`. They must be named:

```
cert.pem       # The certificate
privkey.pem    # Private key
chain.pem      # Full certificate chain
```

If your files have different names, use the environment variables:
- `CERTNAME=my-cert.pem`
- `CERT_PRIVATE_NAME=my-privkey.pem`

For **Let's Encrypt** certificates, the container auto-detects and adds the required CA cert. If your cert is already a chained certificate, set `CERT_IS_CHAIN=true`.

---

## Image Registries

The image is available from two registries:

```bash
# Docker Hub
docker pull networkconcern/unifi:latest

# GitHub Container Registry
docker pull ghcr.io/networkconcern/unifi:latest
```

---

## Architecture Support

Both `linux/amd64` and `linux/arm64` are supported, making this image compatible with:
- Standard x86/x64 servers and desktops
- Synology NAS (most modern models)
- Raspberry Pi 4 / 5
- Apple Silicon (M1/M2/M3) via Docker Desktop

---

## CI/CD Pipeline

This repository uses GitHub Actions to automatically build and publish the Docker image to both Docker Hub and GitHub Container Registry on every push to `master`.

To update the UniFi Controller version:
1. Edit `.github/workflows/build.yml`
2. Change `UNIFI_VERSION: "10.3.58"` to the new version
3. Commit and push — the pipeline does the rest automatically

---

## License

MIT License — see [license](license) file for details.

Maintained by [Network Concern](https://hub.docker.com/r/networkconcern/unifi)
