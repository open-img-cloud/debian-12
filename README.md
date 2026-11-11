# Debian 12 cloud images

Cloud-init-ready, signed Debian 12 (bookworm) qcow2 images for OpenStack and Proxmox,
part of the [openimages.cloud](https://openimages.cloud) catalog.

- Catalog page: <https://openimages.cloud/images/debian-12/>
- Registry: <https://images.openimages.cloud/debian-12/latest/>

## About

Debian 12 "bookworm" is the universal operating system published by the Debian Project ([https://www.debian.org/](https://www.debian.org/)). This repo takes the official upstream
`genericcloud` image ([listing](https://cloud.debian.org/images/cloud/bookworm/)), verifies it against the
upstream `SHA512SUMS`, adds `qemu-guest-agent`, applies the openimages.cloud cloud-init
policy, boot-tests it, signs it with cosign (keyless) and publishes it.

The build pipeline is shared with the rest of
[`open-img-cloud`](https://github.com/open-img-cloud): this repo only ships
`VERSION`, `build/customize.sh`, `build/detect-upstream.sh` and two thin
caller workflows that delegate to the reusable workflows in
[`open-img-cloud/.github`](https://github.com/open-img-cloud/.github).

## Lifecycle

Debian 12 is supported by the Debian LTS team until **2028-06-30**. Debian 13 is the current stable release; prefer it for new deployments.

## Image

- File: `debian-<version>-x86_64.qcow2`, where `<version>` is
  `<major>-<upstream build id>` (e.g. `12-20261026-2643`).
- Default user: `debian` (SSH key from cloud-init, passwordless sudo).
- The root filesystem grows to the flavor disk on first boot.

## Use it

```sh
V=12-20261026-2643
curl -fLO https://images.openimages.cloud/debian-12/$V/debian-$V-x86_64.qcow2

openstack image create \
    --disk-format qcow2 --container-format bare \
    --property hw_qemu_guest_agent=yes \
    --file debian-$V-x86_64.qcow2 \
    'Debian 12 '$V
```

Verification (cosign), Proxmox commands and provenance details are on the
[catalog page](https://openimages.cloud/images/debian-12/) and in the
[verification guide](https://openimages.cloud/verify/).

## Release flow

1. `watch.yml` runs daily (06:32 UTC) and opens an
   `auto/upstream-bump` pull request when upstream publishes a new image.
2. Merge it, then push the tag `v<VERSION>`: `release.yml` builds, boot-tests,
   signs and publishes the image.

## License

The build tooling in this repository is [GPL-2.0](LICENSE). The image keeps
the licensing terms of Debian (DFSG-free software under the licenses of each package). Debian is a trademark of the Debian Project; this project is not affiliated with it.
