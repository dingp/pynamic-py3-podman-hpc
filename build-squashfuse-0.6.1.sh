#!/usr/bin/env bash

set -euo pipefail

VERSION="${VERSION:-0.6.1}"
TARBALL_URL="${TARBALL_URL:-https://github.com/vasi/squashfuse/archive/refs/tags/${VERSION}.tar.gz}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_ROOT="${WORK_ROOT:-${SCRIPT_DIR}/build}"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-${WORK_ROOT}/downloads}"
SRC_ROOT="${SRC_ROOT:-${WORK_ROOT}/src}"
BUILD_ROOT="${BUILD_ROOT:-${WORK_ROOT}/build-${VERSION}}"
INSTALL_DIR="${INSTALL_DIR:-${SCRIPT_DIR}/install_squashfuse_ll}"
TARBALL="${DOWNLOAD_DIR}/squashfuse-${VERSION}.tar.gz"
SOURCE_DIR="${SRC_ROOT}/squashfuse-${VERSION}"
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)}"

usage() {
  cat <<EOF
Build squashfuse_ll from squashfuse release ${VERSION}.

Environment overrides:
  VERSION=0.6.1
  TARBALL_URL=https://github.com/vasi/squashfuse/archive/refs/tags/\${VERSION}.tar.gz
  WORK_ROOT=${WORK_ROOT}
  INSTALL_DIR=${INSTALL_DIR}
  JOBS=${JOBS}
  CONFIGURE_ARGS_EXTRA="..."

Examples:
  ./build-squashfuse-0.6.1.sh
  INSTALL_DIR=/usr/local/libexec/apptainer/bin ./build-squashfuse-0.6.1.sh
  CONFIGURE_ARGS_EXTRA="--with-fuse=/opt/fuse3" ./build-squashfuse-0.6.1.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "error: required command not found: ${cmd}" >&2
    exit 1
  fi
}

require_any_cmd() {
  local found=0
  for cmd in "$@"; do
    if command -v "${cmd}" >/dev/null 2>&1; then
      found=1
      break
    fi
  done
  if [[ "${found}" -eq 0 ]]; then
    echo "error: none of these required commands were found: $*" >&2
    exit 1
  fi
}

for cmd in curl tar make gcc autoreconf aclocal install; do
  require_cmd "${cmd}"
done
require_any_cmd libtoolize glibtoolize
require_any_cmd pkgconf pkg-config

mkdir -p "${DOWNLOAD_DIR}" "${SRC_ROOT}" "${BUILD_ROOT}" "${INSTALL_DIR}"

echo "==> Downloading squashfuse ${VERSION}"
curl -L "${TARBALL_URL}" -o "${TARBALL}"

echo "==> Unpacking source"
rm -rf "${SOURCE_DIR}"
tar -xzf "${TARBALL}" -C "${SRC_ROOT}"

cd "${SOURCE_DIR}"

echo "==> Bootstrapping autotools"
./autogen.sh

CONFIGURE_ARGS=(
  --disable-high-level
  --disable-demo
  --enable-multithreading
  --prefix="${BUILD_ROOT}/prefix"
)

if [[ -n "${CONFIGURE_ARGS_EXTRA:-}" ]]; then
  # Intentional word splitting for user-provided extra configure flags.
  # shellcheck disable=SC2206
  EXTRA_ARGS=(${CONFIGURE_ARGS_EXTRA})
  CONFIGURE_ARGS+=("${EXTRA_ARGS[@]}")
fi

echo "==> Configuring"
./configure "${CONFIGURE_ARGS[@]}"

echo "==> Building squashfuse_ll"
make -j"${JOBS}" squashfuse_ll

echo "==> Installing binary to ${INSTALL_DIR}"
install -m 0755 squashfuse_ll "${INSTALL_DIR}/squashfuse_ll"

echo "Build complete:"
echo "  source:  ${SOURCE_DIR}"
echo "  binary:  ${INSTALL_DIR}/squashfuse_ll"
