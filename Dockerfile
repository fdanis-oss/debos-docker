# Global ARGs shared by all stages
ARG DEBIAN_FRONTEND=noninteractive
ARG GOPATH=/usr/local/go

### first stage - builder ###
FROM debian:stretch-slim as builder

ARG DEBIAN_FRONTEND
ARG GOPATH

# Dependencies to build debos
# - libostree: Latest debos needs version from stretch-backports at least
RUN printf "deb http://httpredir.debian.org/debian stretch-backports main \ndeb-src http://httpredir.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/backports.list && \
    apt-get update && apt-get -t stretch-backports install --no-install-recommends -y \
        ca-certificates \
        golang-go \
        gcc \
        git \
        libostree-dev \
        libc6-dev && \
    rm -rf /var/lib/apt/lists/*

# Build debos
RUN go get github.com/fdanis-oss/debos/cmd/debos && \
    go install github.com/fdanis-oss/debos/cmd/debos

### second stage - runner ###
FROM debian:stretch-slim as runner

ARG DEBIAN_FRONTEND
ARG GOPATH

# Set HOME to a writable directory in case something wants to cache things
ENV HOME=/tmp

# Dependencies to run debos
# - Deboostrap: Bug description: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=806780
#     It was fixed in debootstrap 1.0.96 while Stretch provides 1.0.89.
#     Backports provide 1.0.100.
# - libostree: Latest debos needs version from stretch-backports at least
RUN printf "deb http://httpredir.debian.org/debian stretch-backports main \ndeb-src http://httpredir.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get install -t stretch-backports --no-install-recommends -y \
        apt-transport-https \
        ca-certificates \
        debootstrap \
        pkg-config \
        systemd-container \
        binfmt-support \
        parted \
        dosfstools \
        e2fsprogs \
        btrfs-progs \
        bmap-tools \
        libostree-1-1 \
        # fakemachine runtime dependencies
        qemu-system-x86 \
        qemu-user-static \
        busybox \
        linux-image-amd64 \
        systemd && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder $GOPATH/bin/debos /usr/local/bin/debos
