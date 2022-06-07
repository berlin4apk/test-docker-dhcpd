ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE}

ARG VERSION SHA256

LABEL org.opencontainers.image.authors="Robin Smidsrød <robin@smidsrod.no>"

ARG DEBIAN_FRONTEND=noninteractive

### RUN yes | unminimize
### RUN if [ -x "$(command -v unminimize)" ]; then \
### 	echo "run unminimize" \
### 	export DEBIAN_FRONTEND=noninteractive ; yes | unminimize ;\
### fi

# based of https://github.com/blitterated/docker_dev_env/wiki/Setup-man-pages-in-a-minimized-Ubuntu-container 
RUN if [ -x "$(command -v unminimize)" ]; then \
 apt update \
 && apt --yes upgrade \
 # comment out dpkg exclusion for manpages
 && sed -e '\|/usr/share/man|s|^#*|#|g' -i /etc/dpkg/dpkg.cfg.d/excludes \
 # install manpage packages and dependencies
 && apt --yes install apt-utils dialog manpages manpages-posix man-db less \
 # remove dpkg-divert entries
 && rm -f /usr/bin/man \
 && dpkg-divert --quiet --remove --rename /usr/bin/man \
 && rm -f /usr/share/man/man1/sh.1.gz \
 && dpkg-divert --quiet --remove --rename /usr/share/man/man1/sh.1.gz \
 && apt-get -q -y autoremove \
 && apt-get -q -y clean \
 && rm -rf /var/lib/apt/lists/* ;\
fi

RUN apt-get -q -y update \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install \
     apt-utils dumb-init isc-dhcp-server man \
 && apt-get -q -y autoremove \
 && apt-get -q -y clean \
 && rm -rf /var/lib/apt/lists/*

ENV DHCPD_PROTOCOL=4

COPY util/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
