# pynamic Benchmarking Notes

## Scope

This repository benchmarks `pynamic` under `podman-hpc` in two modes:

- baseline `podman-hpc`
- `podman-hpc` with `squashfuse_ll` via `PODMANHPC_MOUNT_PROGRAM`

The benchmark command used by the runner is:

```bash
./pynamic-mpi4py pynamic_driver_mpi4py.py 1
```

The runner script is:

- [run-pynamic-podman-hpc.sh](/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/pynamic-py3-podman-hpc/run-pynamic-podman-hpc.sh)

The image build script is:

- [build-pynamic-image.sh](/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/pynamic-py3-podman-hpc/build-pynamic-image.sh)

## Local Image Note

If the image is built locally, run:

```bash
podman-hpc migrate <image-name>
podman-hpc rmi <image-name>
```

This ensures the migrated squashed image is the one used by `podman-hpc` during the benchmark, rather than the unsquashed local image.

## squashfuse_ll Setup

The custom wrapper is:

- [fuse-overlayfs-wrap-squashfuse-ll](/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/pynamic-py3-podman-hpc/fuse-overlayfs-wrap-squashfuse-ll)

For reliable benchmark runs, pass the binary path explicitly:

```bash
SQUASHFUSE_LL_BIN=/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/install_squashfuse_ll/squashfuse_ll
```

## Image Configurations

### Default small image

Build shape:

```bash
10 10 --with-mpi4py --with-cc=mpicc -u 2 2 -s 42
```

Default image tag:

```bash
ghcr.io/dingp/pynamic-py3-podman-hpc:1.3.4
```

This imports:

- `8` generated `libmoduleN` extension modules
- `libmodulebegin`
- `libmodulefinal`

Total imported Python extension modules: `10`

### 10x scale-up image

Build shape:

```bash
100 100 --with-mpi4py --with-cc=mpicc -u 20 20 -s 42
```

Derived image tag:

```bash
ghcr.io/dingp/pynamic-py3-podman-hpc:1.3.4-100-100---with-mpi4py---with-ccmpicc--u-20-20--s-42
```

This imports:

- `80` generated `libmoduleN` extension modules
- `libmodulebegin`
- `libmodulefinal`

Total imported Python extension modules: `82`

There are also `20` `libutilityN` shared libraries linked beneath the modules, but they are not imported directly by Python.

## Benchmark Commands

### Small image

```bash
./build-pynamic-image.sh
SQUASHFUSE_LL_BIN=/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/install_squashfuse_ll/squashfuse_ll \
./run-pynamic-podman-hpc.sh
```

### 10x image

```bash
PYDYNAMIC_CONFIG_ARGS="100 100 --with-mpi4py --with-cc=mpicc -u 20 20 -s 42" \
./build-pynamic-image.sh

IMAGE_TAG=ghcr.io/dingp/pynamic-py3-podman-hpc:1.3.4-100-100---with-mpi4py---with-ccmpicc--u-20-20--s-42 \
SQUASHFUSE_LL_BIN=/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/install_squashfuse_ll/squashfuse_ll \
./run-pynamic-podman-hpc.sh
```

## Measured Results

### Small image successful paired runs

Run:

- [20260414T040655Z](/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/pynamic-py3-podman-hpc/runs/20260414T040655Z)

Results:

- baseline import: `0.0044625 s`
- `squashfuse_ll` import: `0.0040843 s`
- import change: `squashfuse_ll` about `8.5%` faster
- baseline fractal mpi: `2.6529 s`
- `squashfuse_ll` fractal mpi: `2.6790 s`
- fractal mpi change: `squashfuse_ll` about `1.0%` slower

Logs:

- [baseline stdout](/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/pynamic-py3-podman-hpc/runs/20260414T040655Z/baseline/stdout.log)
- [squashfuse_ll stdout](/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/pynamic-py3-podman-hpc/runs/20260414T040655Z/squashfuse_ll/stdout.log)

Run:

- [20260414T041608Z](/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/pynamic-py3-podman-hpc/runs/20260414T041608Z)

Results:

- baseline import: `0.0067604 s`
- `squashfuse_ll` import: `0.0065563 s`
- import change: `squashfuse_ll` about `3.0%` faster
- baseline fractal mpi: `2.7306 s`
- `squashfuse_ll` fractal mpi: `2.7093 s`
- fractal mpi change: `squashfuse_ll` about `0.8%` faster

Logs:

- [baseline stdout](/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/pynamic-py3-podman-hpc/runs/20260414T041608Z/baseline/stdout.log)
- [squashfuse_ll stdout](/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/pynamic-py3-podman-hpc/runs/20260414T041608Z/squashfuse_ll/stdout.log)

### 10x scale-up run

Run:

- [20260414T042505Z](/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/pynamic-py3-podman-hpc/runs/20260414T042505Z)

Image:

```bash
ghcr.io/dingp/pynamic-py3-podman-hpc:1.3.4-100-100---with-mpi4py---with-ccmpicc--u-20-20--s-42
```

Results:

- baseline import: `0.1779802 s`
- `squashfuse_ll` import: `0.0798702 s`
- import change: `squashfuse_ll` about `55.1%` faster
- baseline visit: `0.0125732 s`
- `squashfuse_ll` visit: `0.0117640 s`
- visit change: `squashfuse_ll` about `6.4%` faster
- baseline fractal mpi: `2.7288 s`
- `squashfuse_ll` fractal mpi: `2.6392 s`
- fractal mpi change: `squashfuse_ll` about `3.3%` faster

Logs:

- [baseline stdout](/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/pynamic-py3-podman-hpc/runs/20260414T042505Z/baseline/stdout.log)
- [squashfuse_ll stdout](/global/cfs/cdirs/nstaff/dingpf/squashfuse_ll/pynamic-py3-podman-hpc/runs/20260414T042505Z/squashfuse_ll/stdout.log)

## Summary

For the small image, `squashfuse_ll` consistently improved module import time, but the overall runtime impact was small and mixed.

For the 10x scale-up image, `squashfuse_ll` produced a clear import-time improvement and modest end-to-end improvement in the fractal MPI phase. On the current data, the larger import-heavy case shows the strongest benefit.
