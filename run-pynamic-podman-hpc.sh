#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ROOT="${RUN_ROOT:-${SCRIPT_DIR}/runs/${TIMESTAMP}}"

IMAGE_TAG="${IMAGE_TAG:-localhost/pynamic:1.3.4}"
CONTAINERFILE="${CONTAINERFILE:-${SCRIPT_DIR}/Containerfile}"
PODMAN_HPC_BIN="${PODMAN_HPC_BIN:-podman-hpc}"
SQUASHFUSE_MOUNT_PROGRAM="${SQUASHFUSE_MOUNT_PROGRAM:-/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/fuse-overlayfs-wrap-squashfuse-ll}"
PYNAMIC_COMMAND="${PYNAMIC_COMMAND:-./pynamic-mpi4py pynamic_driver_mpi4py.py 1}"

mkdir -p "${RUN_ROOT}"

build_image() {
    "${PODMAN_HPC_BIN}" build -f "${CONTAINERFILE}" -t "${IMAGE_TAG}" "${SCRIPT_DIR}"
}

run_variant() {
    local name="$1"
    local mount_program="${2:-}"
    local variant_dir="${RUN_ROOT}/${name}"
    mkdir -p "${variant_dir}"

    {
        echo "timestamp_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "image=${IMAGE_TAG}"
        echo "command=${PYNAMIC_COMMAND}"
        if [[ -n "${mount_program}" ]]; then
            echo "PODMANHPC_MOUNT_PROGRAM=${mount_program}"
        fi
    } > "${variant_dir}/env.txt"

    if [[ -n "${mount_program}" ]]; then
        PODMANHPC_MOUNT_PROGRAM="${mount_program}" \
            "${PODMAN_HPC_BIN}" run --rm "${IMAGE_TAG}" \
            /bin/bash -lc "${PYNAMIC_COMMAND}" \
            > "${variant_dir}/stdout.log" 2> "${variant_dir}/stderr.log"
    else
        "${PODMAN_HPC_BIN}" run --rm "${IMAGE_TAG}" \
            /bin/bash -lc "${PYNAMIC_COMMAND}" \
            > "${variant_dir}/stdout.log" 2> "${variant_dir}/stderr.log"
    fi
}

build_image
run_variant baseline
run_variant squashfuse_ll "${SQUASHFUSE_MOUNT_PROGRAM}"

printf "variant\tstdout\tstderr\n" > "${RUN_ROOT}/status.tsv"
printf "baseline\t%s\t%s\n" "${RUN_ROOT}/baseline/stdout.log" "${RUN_ROOT}/baseline/stderr.log" >> "${RUN_ROOT}/status.tsv"
printf "squashfuse_ll\t%s\t%s\n" "${RUN_ROOT}/squashfuse_ll/stdout.log" "${RUN_ROOT}/squashfuse_ll/stderr.log" >> "${RUN_ROOT}/status.tsv"

echo "Run artifacts: ${RUN_ROOT}"
