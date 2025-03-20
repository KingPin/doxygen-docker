ARG DISTRO=alpine
ARG DISTRO_VERSION=latest
ARG DEBIAN_VERSION=stable-slim

# First set a default image
FROM ${DISTRO}:${DISTRO_VERSION}

# Re-declare ARG to make it available after FROM
ARG DISTRO=alpine

# Common labels
LABEL org.opencontainers.image.title="Doxygen Docker Image"
LABEL org.opencontainers.image.description="Doxygen container for documentation generation"
LABEL org.opencontainers.image.source="https://github.com/kingpin/doxygen-docker"

# Create non-root user (using appropriate commands for each distro)
RUN if [ "$DISTRO" = "alpine" ]; then \
        addgroup -g 1000 doxygen && \
        adduser -u 1000 -G doxygen -s /bin/sh -D doxygen; \
    else \
        groupadd -g 1000 doxygen && \
        useradd -u 1000 -g doxygen -s /bin/bash -m doxygen; \
    fi

# Set up working directories (common for both distros)
RUN mkdir -p /input /output && \
    chown -R doxygen:doxygen /input /output

# Install required packages (distro-specific)
RUN if [ "$DISTRO" = "alpine" ]; then \
        apk --update --no-cache add \
        doxygen \
        git \
        graphviz \
        && rm -rf /var/cache/apk/*; \
    else \
        apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        doxygen \
        git \
        graphviz \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Switch to non-root user
USER doxygen

# Set working directory
WORKDIR /input

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD doxygen -v || exit 1

# Set entry point
CMD ["doxygen", "/Doxyfile"]