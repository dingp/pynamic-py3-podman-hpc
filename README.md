# pynamic Python 3 podman-hpc port

This repository packages:

- the current `pynamic` source tree based on upstream `master`
- a local Python 3 port for the `mpi4py` build path
- a `Containerfile` that builds the benchmark on top of `ghcr.io/dingp/test-mpi-images:ubuntu-24.04-cuda-13.2.0-cudnn`
- a repeatable `podman-hpc` benchmark runner for baseline versus `squashfuse_ll`
- helper scripts to build `squashfuse_ll` and use it as the `podman-hpc` `mount_program`

## Build the pynamic image

```bash
podman-hpc build -f Containerfile -t localhost/pynamic:1.3.4 .
```

## Build and install squashfuse_ll

The repository includes [build-squashfuse-0.6.1.sh](./build-squashfuse-0.6.1.sh), which builds `squashfuse_ll` from upstream `squashfuse` release `0.6.1`.

Default install location:

```bash
./build-squashfuse-0.6.1.sh
```

This installs the binary at:

```bash
./install_squashfuse_ll/squashfuse_ll
```

If you want a different install path:

```bash
INSTALL_DIR=/some/path ./build-squashfuse-0.6.1.sh
```

## Use squashfuse_ll with podman-hpc

The repository includes [fuse-overlayfs-wrap-squashfuse-ll](./fuse-overlayfs-wrap-squashfuse-ll). It mirrors the site `fuse-overlayfs-wrap` behavior but mounts squashed lowerdirs with the locally built `squashfuse_ll` binary.

By default it expects:

```bash
./install_squashfuse_ll/squashfuse_ll
```

You can use it with `podman-hpc` by exporting:

```bash
export PODMANHPC_MOUNT_PROGRAM="$(pwd)/fuse-overlayfs-wrap-squashfuse-ll"
```

Then run `podman-hpc` normally, for example:

```bash
podman-hpc run --rm localhost/pynamic:1.3.4 python3 pynamic_driver_mpi4py.py 1
```

## Run the comparison benchmark

```bash
./run-pynamic-podman-hpc.sh
```

This script:

- builds `localhost/pynamic:1.3.4`
- runs a baseline `podman-hpc` execution
- runs a `squashfuse_ll` execution using the repository-local `fuse-overlayfs-wrap-squashfuse-ll`

Artifacts are written under `runs/<timestamp>/`.

If you want to use a different wrapper path, override:

```bash
SQUASHFUSE_MOUNT_PROGRAM=/path/to/fuse-overlayfs-wrap-squashfuse-ll ./run-pynamic-podman-hpc.sh
```

## Current scope

The Python 3 port is focused on the `mpi4py` execution path. The older embedded `pyMPI` runtime remains Python 2 oriented.
