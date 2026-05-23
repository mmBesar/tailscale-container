# tailscale-container

Automated multi-arch container builds of [tailscale/tailscale](https://github.com/tailscale/tailscale), published to GHCR.

## Images

```
ghcr.io/mmbesar/tailscale-container:latest      # newest stable release
ghcr.io/mmbesar/tailscale-container:stable      # same as latest
ghcr.io/mmbesar/tailscale-container:unstable    # newest unstable/dev release
ghcr.io/mmbesar/tailscale-container:v1.80.0     # pinned version
```

## Architectures

| Arch | How |
|------|-----|
| `linux/amd64` | Native GitHub runner |
| `linux/arm64` | QEMU on ubuntu-latest |
| `linux/riscv64` | QEMU on ubuntu-latest |

## Versioning

Tailscale uses even minor versions for stable (`v1.80.x`) and odd for unstable (`v1.79.x`).  
This repo mirrors that convention for the floating `stable`, `unstable`, and `latest` tags.

## How it works

- **`upstream-sync.yml`** runs daily at 03:00 UTC, syncs the `upstream` branch from  
  `tailscale/tailscale`, detects new tags, and pushes them to this repo.
- **`container-build.yml`** triggers on any new `v*.*.*` tag, builds all three arches,  
  and publishes the multi-arch manifest to GHCR.
- **`built-tags.txt`** is a ledger of every tag that has been built. The sync workflow  
  skips tags already in this file, so no duplicate builds ever happen.

## Manual build

Trigger `container-build.yml` manually from the Actions tab and enter any valid upstream  
tag (e.g. `v1.80.0`) to force a build of that specific version.
