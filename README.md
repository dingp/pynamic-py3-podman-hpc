# pynamic Python 3 podman-hpc port

This repository packages:

- the current `pynamic` source tree based on upstream `master`
- a local Python 3 port for the `mpi4py` build path
- a `Containerfile` that builds the benchmark on top of `ghcr.io/dingp/test-mpi-images:ubuntu-24.04-cuda-13.2.0-cudnn`
- a repeatable `podman-hpc` benchmark runner for baseline versus `squashfuse_ll`

## Build

```bash
podman-hpc build -f Containerfile -t localhost/pynamic:1.3.4 .
```

## Run

```bash
./run-pynamic-podman-hpc.sh
```

This runs two variants:

- baseline `podman-hpc`
- `podman-hpc` with `PODMANHPC_MOUNT_PROGRAM=/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/fuse-overlayfs-wrap-squashfuse-ll`

Artifacts are written under `runs/<timestamp>/`.

## Current scope

The Python 3 port is focused on the `mpi4py` execution path. The older embedded `pyMPI` runtime remains Python 2 oriented.
