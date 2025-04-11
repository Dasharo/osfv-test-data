#!/bin/bash
set -e

# SDK and config
IMAGE="ghcr.io/tianocore/containers/fedora-39-build:b4ea0a6"
TARGET_ARCH="X64"
TOOLCHAIN="GCC5"

# Script paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EDK2_DIR="${SCRIPT_DIR}/edk2"
GENERATED_FILE="${EDK2_DIR}/Build/Shell/RELEASE_GCC5/X64/ShellPkg/Application/Shell/Shell/OUTPUT/Shell.efi"


if [ -d ${EDK2_DIR} ]; then
    cd ${EDK2_DIR}
    rm -r ${EDK2_DIR}/Build
    git pull
else
    git clone https://github.com/Dasharo/edk2.git ${EDK2_DIR}
    cd ${EDK2_DIR}
fi

git submodule update --init
docker run --rm -it \
    -v "${EDK2_DIR}:/home/edk2" \
    -w /home/edk2 \
    --user "$(id -u):$(id -g)" \
    "$IMAGE" \
    bash -c "
        set -e
        source edksetup.sh
        make -C BaseTools -j
        build -a ${TARGET_ARCH} -t ${TOOLCHAIN} -b RELEASE -p ShellPkg/ShellPkg.dsc
    "

if [[ -f "$GENERATED_FILE" ]]; then
    cp ${GENERATED_FILE} ${SCRIPT_DIR}/Shell.efi
    echo "UEFI Shell built successfully: $SCRIPT_DIR/Shell.efi"
else
    echo "UEFI Shell binary not found!"
    exit 1
fi
