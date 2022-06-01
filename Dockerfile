ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE}

ARG VERSION SHA256

LABEL org.opencontainers.image.authors="Robin Smidsrød <robin@smidsrod.no>"

ARG DEBIAN_FRONTEND=noninteractive

RUN [[ command -v unminimize ]] && sh -c 'export DEBIAN_FRONTEND=noninteractive ; yes | unminimize'

RUN apt-get -q -y update \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install \
     apt-utils dumb-init isc-dhcp-server man \
 && apt-get -q -y autoremove \
 && apt-get -q -y clean \
 && rm -rf /var/lib/apt/lists/*

ENV DHCPD_PROTOCOL=4

COPY util/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
