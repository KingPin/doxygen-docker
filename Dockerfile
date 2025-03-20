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

# Install required packages (distro-specific) - including tools for the entrypoint
RUN if [ -f /etc/alpine-release ]; then \
        apk --update --no-cache add \
        doxygen \
        git \
        graphviz \
        bash \
        su-exec \
        shadow \
        && rm -rf /var/cache/apk/*; \
    else \
        apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        doxygen \
        git \
        graphviz \
        gosu \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Create non-root user (using appropriate commands for each distro)
RUN if [ -f /etc/alpine-release ]; then \
        addgroup -g 1000 doxygen && \
        adduser -u 1000 -G doxygen -s /bin/sh -D doxygen; \
    elif [ -f /etc/debian_version ]; then \
        groupadd -g 1000 doxygen && \
        useradd -u 1000 -g doxygen -s /bin/bash -m doxygen; \
    else \
        echo "Unsupported distribution" && exit 1; \
    fi

# Set up working directories (common for both distros)
RUN mkdir -p /input /output && \
    chown -R doxygen:doxygen /input /output

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set working directory
WORKDIR /input

# Switch to non-root user by default
USER doxygen

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD doxygen -v || exit 1

# Set entry point
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["doxygen", "/Doxyfile"]