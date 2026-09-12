# syntax=docker/dockerfile:1
#
# Purpose-built Dockerfile for mmBesar/tailscale-container
# https://github.com/mmBesar/tailscale-container
#
# Supports: linux/amd64 · linux/arm64 · linux/riscv64
#
# Uses the official Go image instead of Tailscale's custom Go toolchain fork,
# which only publishes amd64 and arm64 builds and has no riscv64 support.
# See: https://github.com/tailscale/go/releases
# See: https://github.com/tailscale/tailscale/issues/17812

# ---- build stage --------------------------------------------------------
FROM golang:alpine AS build-env

RUN apk add --no-cache git curl

WORKDIR /go/src/tailscale

# Copy dependency manifests first — changes here invalidate the module cache
# layer but not the expensive pre-build layer below
COPY go.mod go.sum ./
RUN go mod download

# Pre-build heavy dependencies before COPY . invalidates the Docker cache.
# Matches the set used in Tailscale's own Dockerfile.
RUN go install \
    github.com/aws/aws-sdk-go-v2/aws \
    github.com/aws/aws-sdk-go-v2/config \
    gvisor.dev/gvisor/pkg/tcpip/adapters/gonet \
    gvisor.dev/gvisor/pkg/tcpip/stack \
    golang.org/x/crypto/ssh \
    golang.org/x/crypto/acme \
    github.com/coder/websocket \
    github.com/mdlayher/netlink

COPY . .

ARG TARGETARCH
ARG VERSION_LONG=""
ARG VERSION_SHORT=""
ARG VERSION_GIT_HASH=""

RUN GOARCH=$TARGETARCH go install -ldflags="\
      -X tailscale.com/version.longStamp=${VERSION_LONG} \
      -X tailscale.com/version.shortStamp=${VERSION_SHORT} \
      -X tailscale.com/version.gitCommitStamp=${VERSION_GIT_HASH}" \
      -v ./cmd/tailscale ./cmd/tailscaled ./cmd/containerboot

# ---- runtime stage ------------------------------------------------------
FROM alpine:3.22

RUN apk add --no-cache ca-certificates iptables iproute2 ip6tables

# Alpine 3.19+ replaced legacy iptables with nftables. Some hosts (e.g.
# Synology NAS) don't support nftables, so link back to legacy iptables.
# See: https://github.com/tailscale/tailscale/issues/17854
RUN rm /usr/sbin/iptables && ln -s /usr/sbin/iptables-legacy /usr/sbin/iptables
RUN rm /usr/sbin/ip6tables && ln -s /usr/sbin/ip6tables-legacy /usr/sbin/ip6tables

COPY --from=build-env /go/bin/* /usr/local/bin/

# Compatibility symlink for older run.sh entrypoint convention
RUN mkdir /tailscale && ln -s /usr/local/bin/containerboot /tailscale/run.sh
