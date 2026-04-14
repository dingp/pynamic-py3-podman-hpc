#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONTAINERFILE="${CONTAINERFILE:-${SCRIPT_DIR}/Containerfile}"
PODMAN_HPC_BIN="${PODMAN_HPC_BIN:-podman-hpc}"
PYDYNAMIC_CONFIG_ARGS="${PYDYNAMIC_CONFIG_ARGS:-100 100 --with-mpi4py --with-cc=mpicc -u 20 20 -s 42}"
TAG_SUFFIX=$(printf '%s' "${PYDYNAMIC_CONFIG_ARGS}" | tr ' ' '-' | tr -cd '[:alnum:]-')
IMAGE_TAG="${IMAGE_TAG:-ghcr.io/dingp/pynamic-py3-podman-hpc:1.3.4-${TAG_SUFFIX}}"

"${PODMAN_HPC_BIN}" build     --build-arg "PYDYNAMIC_CONFIG_ARGS=${PYDYNAMIC_CONFIG_ARGS}"     -f "${CONTAINERFILE}"     -t "${IMAGE_TAG}"     "${SCRIPT_DIR}"
