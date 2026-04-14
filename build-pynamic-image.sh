#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
IMAGE_TAG="${IMAGE_TAG:-ghcr.io/dingp/pynamic-py3-podman-hpc:1.3.4}"
CONTAINERFILE="${CONTAINERFILE:-${SCRIPT_DIR}/Containerfile}"
PODMAN_HPC_BIN="${PODMAN_HPC_BIN:-podman-hpc}"

"${PODMAN_HPC_BIN}" build -f "${CONTAINERFILE}" -t "${IMAGE_TAG}" "${SCRIPT_DIR}"
