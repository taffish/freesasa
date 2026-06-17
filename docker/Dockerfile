FROM debian:12-slim AS builder

ARG FREESASA_VERSION=2.1.3
ARG FREESASA_SHA256=dc4fe377352569299d69329d9ded2f141e527da325960b20d2e30b5335c2b3ff
ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get -o Acquire::Retries=5 update; \
    for attempt in 1 2 3 4 5; do \
        if apt-get -o Acquire::Retries=5 install -y --no-install-recommends \
            autoconf \
            automake \
            ca-certificates \
            curl \
            g++ \
            gcc \
            libc6-dev \
            libjson-c-dev \
            libtool \
            libxml2-dev \
            libxml2-utils \
            make \
            pkg-config; then \
            break; \
        fi; \
        if [ "$attempt" = 5 ]; then exit 1; fi; \
        apt-get -o Acquire::Retries=5 update; \
        sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/freesasa-build

RUN set -eux; \
    curl -fsSL -o freesasa.tar.gz "https://github.com/mittinatten/freesasa/archive/refs/tags/${FREESASA_VERSION}.tar.gz"; \
    echo "${FREESASA_SHA256}  freesasa.tar.gz" | sha256sum -c -; \
    mkdir src; \
    tar -xzf freesasa.tar.gz -C src --strip-components=1

WORKDIR /tmp/freesasa-build/src

RUN set -eux; \
    autoreconf -i; \
    ./configure --prefix=/opt/freesasa; \
    make -j"$(nproc)"; \
    make install; \
    mkdir -p /opt/freesasa/share/doc/freesasa /opt/freesasa/share/licenses/freesasa /opt/freesasa/share/testdata; \
    cp README.md CHANGELOG.md INSTALL /opt/freesasa/share/doc/freesasa/; \
    cp LICENSE /opt/freesasa/share/licenses/freesasa/LICENSE; \
    cp third-party/gemmi/LICENSE.txt /opt/freesasa/share/licenses/freesasa/GEMMI-MPL-2.0-LICENSE.txt; \
    cp tests/data/1ubq.pdb tests/data/1ubq.cif tests/data/test.config /opt/freesasa/share/testdata/; \
    { \
        echo "FreeSASA ${FREESASA_VERSION}"; \
        echo "source=https://github.com/mittinatten/freesasa/archive/refs/tags/${FREESASA_VERSION}.tar.gz"; \
        echo "sha256=${FREESASA_SHA256}"; \
        echo "upstream_commit=ef5f27028447161bff0f2b67d05b74bb54c46eab"; \
        echo "build=source, autoreconf, json+xml+threads enabled"; \
        echo "third_party=Gemmi headers bundled by upstream, MPL-2.0"; \
    } > /opt/freesasa/share/doc/freesasa/source.txt

FROM debian:12-slim

ARG FREESASA_VERSION=2.1.3
ARG FREESASA_SHA256=dc4fe377352569299d69329d9ded2f141e527da325960b20d2e30b5335c2b3ff
ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get -o Acquire::Retries=5 update; \
    for attempt in 1 2 3 4 5; do \
        if apt-get -o Acquire::Retries=5 install -y --no-install-recommends \
            ca-certificates \
            grep \
            libc-bin \
            libjson-c5 \
            libstdc++6 \
            libxml2 \
            sed; then \
            break; \
        fi; \
        if [ "$attempt" = 5 ]; then exit 1; fi; \
        apt-get -o Acquire::Retries=5 update; \
        sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/freesasa /opt/freesasa

RUN set -eux; \
    echo /opt/freesasa/lib > /etc/ld.so.conf.d/freesasa.conf; \
    ldconfig; \
    ln -s /opt/freesasa/bin/freesasa /usr/local/bin/freesasa; \
    chmod -R a+rX /opt/freesasa

WORKDIR /root

ENV TAFFISH_ENV=TAFFISH
ENV TAFFISH_NAME=freesasa

RUN set -eux; \
    command -v freesasa >/dev/null; \
    grep -Fx "FreeSASA ${FREESASA_VERSION}" /opt/freesasa/share/doc/freesasa/source.txt >/dev/null; \
    grep -F "sha256=${FREESASA_SHA256}" /opt/freesasa/share/doc/freesasa/source.txt >/dev/null; \
    test -s /opt/freesasa/include/freesasa.h; \
    test -s /opt/freesasa/lib/libfreesasa.a; \
    test -s /opt/freesasa/share/freesasa/protor.config; \
    test -s /opt/freesasa/share/testdata/1ubq.pdb; \
    test -s /opt/freesasa/share/testdata/1ubq.cif; \
    freesasa --version 2>&1 | grep -F "FreeSASA ${FREESASA_VERSION}" >/dev/null; \
    freesasa --help 2>&1 | grep -F "Usage: freesasa" >/dev/null; \
    freesasa --help 2>&1 | grep -F -- "--format=<log|res|seq|pdb|rsa|cif|xml|json>" >/dev/null; \
    tmp=/tmp/taf-freesasa-build-check; \
    rm -rf "$tmp"; \
    mkdir -p "$tmp"; \
    freesasa --format=json --depth=atom -o "$tmp/1ubq.json" /opt/freesasa/share/testdata/1ubq.pdb; \
    test -s "$tmp/1ubq.json"; \
    grep -F '"total"' "$tmp/1ubq.json" >/dev/null; \
    freesasa --cif --format=xml -o "$tmp/1ubq.xml" /opt/freesasa/share/testdata/1ubq.cif; \
    test -s "$tmp/1ubq.xml"; \
    grep -F '<results xmlns="http://freesasa.github.io/"' "$tmp/1ubq.xml" >/dev/null; \
    grep -F '<area total=' "$tmp/1ubq.xml" >/dev/null; \
    freesasa --select="ubiq, chain A" --format=seq -o "$tmp/select.seq" /opt/freesasa/share/testdata/1ubq.pdb; \
    test -s "$tmp/select.seq"; \
    grep -F 'SEQ A' "$tmp/select.seq" >/dev/null; \
    rm -rf "$tmp"; \
    ldd "$(command -v freesasa)" > /tmp/freesasa-ldd.txt; \
    if grep -F "not found" /tmp/freesasa-ldd.txt; then exit 1; fi; \
    rm -f /tmp/freesasa-ldd.txt
