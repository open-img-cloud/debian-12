#!/usr/bin/env bash
# Prints the latest upstream Debian 12 cloud image version on stdout.
#
# Parses the directory listing at
#   https://cloud.debian.org/images/cloud/bookworm/
# for dated build directories and prints <12>-<build id> for the highest
# one that holds the image (e.g. 12-20261026-2643). Runs in the upstream-watch reusable workflow
# (no KVM needed): keep it portable bash + curl + grep + sort only.

set -euo pipefail

URL='https://cloud.debian.org/images/cloud/bookworm/'

listing=$(curl -fsL "$URL")
if [[ -z "$listing" ]]; then
  echo "::error::could not fetch $URL" >&2
  exit 1
fi

# Debian publishes a build directory before every image of it is uploaded
# (20261111-2659 first had only the azure and ec2 images): take the newest
# directory that already holds our amd64 generic qcow2.
latest=''
for dir in $(printf '%s\n' "$listing" \
  | grep -oE 'href="[0-9]{8}-[0-9]+/"' \
  | sed -E 's#href="([0-9]{8}-[0-9]+)/"#\1#' \
  | sort -uVr \
  | head -n5); do
  files=$(curl -fsL "$URL$dir/" || true)
  if [[ "$files" == *"debian-12-generic-amd64-$dir.qcow2"* ]]; then
    latest=$dir
    break
  fi
done

if [[ -z "$latest" ]]; then
  echo "::error::no build directory found in $URL" >&2
  exit 1
fi

printf '12-%s\n' "$latest"
