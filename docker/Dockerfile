# Both stages use the same verified multi-platform Debian index. If the
# registry loses it, restore that digest or review a new base on both CPUs.
FROM debian:12-slim@sha256:734a72b3d6142a71993b4bc580ca01d8ca687f77a2c422d96a961d3376b179bc AS builder
# Bookworm and its security mirrors are live. For the identical dependency
# set use a verified snapshot/debs; do not silently substitute a revision.
RUN apt-get -o Acquire::Retries=3 update \
 && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
      autoconf automake ca-certificates curl g++ gcc libc6-dev libjson-c-dev \
      libtool libxml2-dev libxml2-utils make pkg-config \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /build
# Use the full upstream commit, not a movable tag. The commit archive includes
# the original FreeSASA, Gemmi and PEGTL licenses. If archive bytes change,
# restore the verified archive or audit the new bytes; never skip the hash.
RUN set -eu; \
    commit=f5bc39f3cc6418db35455783609058bfa702cccb; \
    digest=2c670d5186235b40b421e37e4240da939a4135270a036184ad7ad06ac008923e; \
    url="https://codeload.github.com/mittinatten/freesasa/tar.gz/$commit"; \
    curl --fail --location --silent --show-error --retry 3 -o source.tar.gz "$url"; \
    echo "$digest  source.tar.gz" | sha256sum -c -; \
    tar -xzf source.tar.gz; cd "freesasa-$commit"; \
    autoreconf -i; ./configure --prefix=/opt/freesasa --enable-json --enable-xml --enable-threads; \
    make -j2; make install; \
    prefix=/opt/freesasa/share; \
    install -d -m 0755 "$prefix/doc/freesasa" "$prefix/licenses/freesasa" "$prefix/testdata"; \
    install -m 0644 README.md CHANGELOG.md INSTALL "$prefix/doc/freesasa/"; \
    install -m 0644 LICENSE "$prefix/licenses/freesasa/LICENSE"; \
    install -m 0644 third-party/gemmi/LICENSE.txt "$prefix/licenses/freesasa/GEMMI-MPL-2.0-LICENSE.txt"; \
    install -m 0644 third-party/gemmi/include/gemmi/third_party/tao/LICENSE "$prefix/licenses/freesasa/PEGTL-MIT.txt"; \
    install -m 0644 tests/data/1ubq.pdb tests/data/1ubq.cif tests/data/test.config "$prefix/testdata/"; \
    printf 'FreeSASA 2.1.4\nupstream_commit=%s\nsource=%s\nsha256=%s\n' "$commit" "$url" "$digest" > "$prefix/doc/freesasa/source.txt"; \
    cd "$prefix/freesasa"; sha256sum *.config > "$prefix/doc/freesasa/classifiers.sha256"

# Keep the public development archive intact; the CLI does not use DWARF data.
RUN strip --strip-debug /opt/freesasa/bin/freesasa

FROM debian:12-slim@sha256:734a72b3d6142a71993b4bc580ca01d8ca687f77a2c422d96a961d3376b179bc
# Runtime libraries follow the same live Bookworm sources as the builder.
# Inspect the installed versions or use verified snapshots for a past rebuild.
RUN apt-get -o Acquire::Retries=3 update \
 && apt-get -o Acquire::Retries=3 install -y --no-install-recommends ca-certificates libjson-c5 libstdc++6 libxml2 \
 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /opt/freesasa/ /opt/freesasa/
COPY --chmod=0755 docker/smoke.sh /usr/local/libexec/taf-freesasa-smoke
ENV TAFFISH_ENV=TAFFISH
ENV TAFFISH_NAME=freesasa
WORKDIR /tmp
# Build-time checks are intentionally format- and CPU-independent. Validate
# numerical results, file formats, linking and permissions with the final image.
RUN set -eu; \
    ln -s /opt/freesasa/bin/freesasa /usr/local/bin/freesasa; \
    version=$(freesasa --version 2>&1) || { rc=$?; printf 'build-stage=version exit=%s\n%s\n' "$rc" "$version" >&2; exit "$rc"; }; \
    printf '%s\n' "$version"; \
    printf '%s\n' "$version" | grep -Fx 'FreeSASA 2.1.4'
