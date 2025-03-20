# Doxygen Docker

<div align="center">

[![Docker Build](https://img.shields.io/github/actions/workflow/status/kingpin/doxygen-docker/docker-publish.yml?branch=main&label=build&logo=github&style=flat-square)](https://github.com/kingpin/doxygen-docker/actions/workflows/docker-publish.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/kingpin/doxygen-docker?color=blue&logo=docker&style=flat-square)](https://hub.docker.com/r/kingpin/doxygen-docker)
[![Image Size](https://img.shields.io/docker/image-size/kingpin/doxygen-docker/latest?logo=docker&style=flat-square)](https://hub.docker.com/r/kingpin/doxygen-docker)

*Ready-to-use containerized Doxygen for documentation generation with multi-architecture support*
</div>

## 📋 Table of Contents
- [Quick Start](#-quick-start)
- [Available Images](#-available-images)
- [Usage Examples](#-usage-examples)
- [Volume Mounting Guide](#-volume-mounting-guide)
- [Permission Handling](#-permission-handling)
- [Integration Examples](#-integration-examples)
- [Troubleshooting](#-troubleshooting)
- [Security](#-security)
- [Contributing](#-contributing)

## 🚀 Quick Start

```bash
docker run --rm -v $(pwd):/input -v $(pwd)/docs:/output ghcr.io/kingpin/doxygen-docker:latest
```

## 📦 Available Images

### Container Registries

| Registry | Image Path |
|----------|------------|
| GitHub Container Registry | `ghcr.io/kingpin/doxygen-docker` |
| Docker Hub | `docker.io/kingpin/doxygen-docker` |
| Quay.io | `quay.io/kingpinx1/doxygen-docker` |

### Base OS Options

| OS | Description | Image Size |
|----|-------------|------------|
| Alpine | Lightweight container | ~30MB |
| Debian | Standard container with additional tools | ~120MB |

### Available Tags

| Tag Format | Example | Description |
|------------|---------|-------------|
| `latest` | `latest` | Latest Alpine-based image |
| `alpine` | `alpine` | Latest Alpine-based image |
| `alpine-x.x.x` | `alpine-1.9.8` | Alpine with specific Doxygen version |
| `debian` | `debian` | Latest Debian-based image |
| `debian-x.x.x` | `debian-1.9.4` | Debian with specific Doxygen version |
| `pr-XX` | `pr-42` | PR testing build (GitHub only) |

### Multi-architecture Support

All images are built for:
- `linux/amd64` - Intel/AMD 64-bit systems
- `linux/arm64` - ARM 64-bit systems (like Raspberry Pi 4, Apple M1/M2)
- `linux/arm/v7` - ARM 32-bit systems (like Raspberry Pi 3)

## 🧑‍💻 Usage Examples

### Basic Usage with Default Doxyfile

```bash
docker run --rm \
  -v $(pwd):/input \
  -v $(pwd)/docs:/output \
  -v $(pwd)/Doxyfile:/Doxyfile \
  ghcr.io/kingpin/doxygen-docker:latest
```

### Generate a Default Doxyfile in Current Directory

```bash
docker run --rm \
  -v $(pwd):/input \
  ghcr.io/kingpin/doxygen-docker:latest doxygen -g
```

### Run with Custom Doxyfile Location

```bash
docker run --rm \
  -v $(pwd):/input \
  -v $(pwd)/docs:/output \
  -v $(pwd)/config/my-doxyfile:/custom-doxyfile \
  ghcr.io/kingpin/doxygen-docker:latest doxygen /custom-doxyfile
```

### Run with Custom Working Directory Structure

```bash
docker run --rm \
  -v $(pwd)/src:/input/src \
  -v $(pwd)/include:/input/include \
  -v $(pwd)/docs:/output \
  -v $(pwd)/doxygen.conf:/Doxyfile \
  ghcr.io/kingpin/doxygen-docker:latest
```

### Use a Specific Version

```bash
docker run --rm \
  -v $(pwd):/input \
  docker.io/kingpin/doxygen-docker:debian-1.9.4 doxygen Doxyfile
```

## 📁 Volume Mounting Guide

| Container Path | Description | Recommended Host Mount |
|----------------|-------------|------------------------|
| `/input` | Source code directory | `$(pwd)` or `$(pwd)/src` |
| `/output` | Generated documentation | `$(pwd)/docs` or `$(pwd)/build/docs` |
| `/Doxyfile` | Doxygen configuration file | `$(pwd)/Doxyfile` or `$(pwd)/doxygen.conf` |

## 🔐 Permission Handling

### Using PUID/PGID For File Ownership

To ensure files created in mounted volumes have the correct ownership:

```bash
docker run --rm \
  -v $(pwd):/input \
  -v $(pwd)/docs:/output \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  ghcr.io/kingpin/doxygen-docker:latest
```

This matches the container's user with your host user ID, ensuring proper file permissions.

### Common Permission Issues

If you encounter permission errors, try:

1. Use PUID/PGID as shown above
2. Ensure host directories exist with proper permissions before mounting
3. For CI/CD environments, add an explicit chmod step

## 🔄 Integration Examples

### GitLab CI Integration

```yaml
documentation:
  image: ghcr.io/kingpin/doxygen-docker:latest
  script:
    - doxygen Doxyfile
  artifacts:
    paths:
      - docs/html
```

### Docker Compose Example

```yaml
version: '3'
services:
  doxygen:
    image: ghcr.io/kingpin/doxygen-docker:latest
    volumes:
      - ./src:/input
      - ./docs:/output
      - ./Doxyfile:/Doxyfile
    environment:
      - PUID=1000
      - PGID=1000
```

### GitHub Actions Example

```yaml
- name: Generate Documentation
  uses: docker://ghcr.io/kingpin/doxygen-docker:latest
  with:
    args: doxygen Doxyfile
  env:
    PUID: 1000
    PGID: 1000
```

## ❓ Troubleshooting

### "No such file" Errors

Make sure your Doxyfile is accessible inside the container. If your Doxyfile references paths, ensure they're relative to the container's `/input` directory.

### Empty Output

Check that:
1. Your Doxyfile has the correct input/output paths
2. Output directory is properly mounted
3. Source files are in the expected format

### Permission Denied Errors

Use the PUID/PGID environment variables as described in the [Permission Handling](#-permission-handling) section.

## 🛡️ Security

- Images are regularly scanned for vulnerabilities using Trivy
- We follow a minimal installation approach to reduce attack surface
- Alpine-based images are recommended for production use
- We use non-root users by default

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

For more details and tutorials, visit: [Installing and Using Doxygen via Docker](https://sumguy.com/install-use-doxygen-via-docker/)
