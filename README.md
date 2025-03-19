
# Doxygen in Docker

This project provides ready-to-use Doxygen Docker images for documentation generation.

## Quick Start

```bash
docker  run  --rm  -it  -v  ./source:/docs/source  -v  ./output:/docs/output  -v  ./Doxyfile:/docs/Doxyfile  ghcr.io/kingpin/doxygen-docker:latest
```
Container Registries
Images are available on multiple registries:

 - GitHub: ghcr.io/kingpin/doxygen-docker 
 - Docker Hub: docker.io/kingpin/doxygen-docker 
 - Quay.io: quay.io/kingpinx1/doxygen-docker

Base OS Options

 - Alpine: Lightweight container based on Alpine Linux 
 - Debian: Standard container based on Debian stable-slim

Available Tags

 - latest 
	 - Uses Alpine as the base container with latest available Doxygen
 - alpine
	 - Uses Alpine as the base container with latest available Doxygen
 - alpine-x.x.x
	 - Alpine with specific Doxygen version (e.g., alpine-1.9.8) 
 - debian
	 - Uses Debian as the base container with latest available Doxygen 
 - debian-x.x.x
	 - Debian with specific Doxygen version (e.g., debian-1.9.4) 
 - pr-XX (only on GitHub Container Registry)
	 - PR-specific builds for testing, where XX is the pull request number

Multi-architecture Support

All images are built for:

 - linux/amd64 (Intel/AMD)
 - linux/arm64 (ARM 64-bit)
 - linux/arm/v7 (ARM 32-bit)

Usage Examples
Basic Usage

```bash
docker  run  --rm  -v $(pwd)/source:/docs/source  \
-v $(pwd)/output:/docs/output \
-v $(pwd)/Doxyfile:/docs/Doxyfile  \
ghcr.io/kingpin/doxygen-docker:latest
```
Generate a default Doxyfile
```bash
docker  run  --rm  -v $(pwd):/docs  ghcr.io/kingpin/doxygen-docker:latest  doxygen  -g
```
Run with a specific version
```bash
docker  run  --rm  -v $(pwd):/docs  docker.io/kingpin/doxygen-docker:debian-1.9.4  doxygen  Doxyfile
```
Using Alpine-based image

```bash
docker  run  --rm  -v $(pwd):/docs  quay.io/kingpinx1/doxygen-docker:alpine  doxygen  Doxyfile
```
Security
Images are regularly scanned for vulnerabilities using Trivy.

Further Information
For more details and tutorials, visit: https://sumguy.com/install-use-doxygen-via-docker/ 
