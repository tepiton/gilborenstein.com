# Build environment for build.sh — the same packages the GitHub Actions
# workflow installs (.github/workflows/pages.yml), on the same Ubuntu
# release as its ubuntu-latest runner, so local output matches CI.
#
# The repo is bind-mounted at /work rather than copied in, so the image
# only needs rebuilding when the package list changes.
FROM ubuntu:24.04

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      pandoc weasyprint fonts-crosextra-carlito git \
 && rm -rf /var/lib/apt/lists/*

# The mounted repo is owned by the host user, not the container's root;
# without this git refuses to read it and build.sh can't date resume.md.
RUN git config --system --add safe.directory '*'

WORKDIR /work
ENTRYPOINT ["./build.sh"]
