# tailscale-container

> ⚠️ **Personal project** — built for my own use. Issues with Tailscale itself should be reported to [tailscale/tailscale](https://github.com/tailscale/tailscale/issues). This repo only deals with the container image build pipeline.

---

[![Upstream Sync](https://img.shields.io/github/actions/workflow/status/mmBesar/tailscale-container/upstream-sync.yml?label=upstream%20sync&logo=github&logoColor=white)](https://github.com/mmBesar/tailscale-container/actions/workflows/upstream-sync.yml)
[![Container Build](https://img.shields.io/github/actions/workflow/status/mmBesar/tailscale-container/container-build.yml?label=container%20build&logo=docker&logoColor=white)](https://github.com/mmBesar/tailscale-container/actions/workflows/container-build.yml)
[![Image on GHCR](https://img.shields.io/badge/GHCR-ghcr.io%2Fmmbesar%2Ftailscale--container-blue?logo=github&logoColor=white)](https://github.com/mmBesar/tailscale-container/pkgs/container/tailscale-container)
[![License](https://img.shields.io/badge/license-BSD--3--Clause-green?logo=opensourceinitiative&logoColor=white)](https://github.com/tailscale/tailscale/blob/main/LICENSE)

---

## Why this exists

The official [Tailscale container image](https://hub.docker.com/r/tailscale/tailscale) does not publish builds for **RISC-V (linux/riscv64)**. This repo automatically builds and publishes multi-arch images that include RISC-V support, syncing daily from the upstream Tailscale source.

This is a personal project — no guarantees, no support. Use at your own risk.

---

## Images

```sh
# Latest stable release (recommended)
docker pull ghcr.io/mmbesar/tailscale-container:latest
docker pull ghcr.io/mmbesar/tailscale-container:stable

# Latest unstable/dev release
docker pull ghcr.io/mmbesar/tailscale-container:unstable

# Pinned version
docker pull ghcr.io/mmbesar/tailscale-container:v1.98.3
```

---

## Supported architectures

| Architecture | Runner |
|---|---|
| `linux/amd64` | GitHub-hosted (`ubuntu-latest`) |
| `linux/arm64` | GitHub-hosted (`ubuntu-24.04-arm`) |
| `linux/riscv64` | Native RISC-V ([RISE Project runners](https://riseproject.dev)) |

All three are combined into a single multi-arch manifest — Docker picks the right one automatically for your platform.

---

## Versioning

Tailscale uses even minor versions for stable releases and odd for unstable/dev:

| Minor version | Channel | Tags applied |
|---|---|---|
| Even (`v1.98.x`) | Stable | `vX.Y.Z` · `stable` · `latest` |
| Odd (`v1.97.x`) | Unstable | `vX.Y.Z` · `unstable` |

---

## How it works

```
tailscale/tailscale (upstream)
        ↓  daily sync (03:00 UTC)
mmBesar/tailscale-container — upstream branch
        ↓  new version detected → build triggered
ghcr.io/mmbesar/tailscale-container
```

- **`upstream-sync.yml`** runs daily, mirrors the upstream source, detects new version tags by comparing against `built-tags.txt`, and triggers the build workflow via the GitHub API.
- **`container-build.yml`** builds native images for all three architectures in parallel, then merges them into a single multi-arch manifest on GHCR.
- **`built-tags.txt`** is a simple ledger of every version that has been built — preventing duplicate builds.

---

## Credit

All credit goes to the [Tailscale team](https://github.com/tailscale/tailscale) and contributors. This repo contains no Tailscale source code — it only automates building their published source into container images.

- Upstream source: [tailscale/tailscale](https://github.com/tailscale/tailscale)
- Official images: [tailscale/tailscale on Docker Hub](https://hub.docker.com/r/tailscale/tailscale)
- License: [BSD 3-Clause](https://github.com/tailscale/tailscale/blob/main/LICENSE)

---

## Issues & bugs

**Problems with Tailscale itself** → [tailscale/tailscale issues](https://github.com/tailscale/tailscale/issues)
