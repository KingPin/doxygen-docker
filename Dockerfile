ARG BASEOS
FROM ${BASEOS}:latest
ARG BASEOS

RUN if [ "$BASEOS" = "stable-slim" ]; then \
        # echo 'deb http://deb.debian.org/debian bullseye-backports main' > /etc/apt/sources.list.d/bullseye-backports.list  && \
        RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y doxygen graphviz git && \
        rm -rf /var/lib/apt/lists/* \
    fi

# install dependencies for alpine
RUN if [ "$BASEOS" = "alpine" ]; then \
        apk --update --no-cache add doxygen graphviz git
    fi

CMD ["doxygen", "/Doxygen"]
