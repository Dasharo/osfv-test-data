#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /path/to/Shell.efi"
    exit 1
fi

SHELL_EFI_SRC="$1"

if [[ ! -f "$SHELL_EFI_SRC" ]]; then
    echo "Error: File not found: $SHELL_EFI_SRC"
    exit 1
fi

ESP=$(findmnt -no TARGET /boot/efi 2>/dev/null || true)

if [[ -z "$ESP" ]]; then
    echo "Could not detect mounted EFI System Partition."
    exit 1
fi

echo "EFI partition mounted at: $ESP"

DEST_DIR="${ESP}/EFI/Shell"
DEST_EFI="${DEST_DIR}/Shell.efi"

echo "Installing to: $DEST_EFI"
mkdir -p "$DEST_DIR"
cp "$SHELL_EFI_SRC" "$DEST_EFI"

PART_DEV=$(findmnt -no SOURCE "$ESP")
DISK=$(lsblk -no PKNAME "$PART_DEV" | head -n1)
PART_NUM=$(echo "$PART_DEV" | sed -E 's/.*[^0-9]([0-9]+)$/\1/')
DISK_DEV="/dev/$DISK"
LABEL="UEFI Shell"

# Remove existing UEFI Shell entries
efibootmgr | grep "$LABEL" | while IFS= read -r line; do
    # Extract the boot number Boot0003 -> 0003
    bootnum=$(echo "$line" | grep -oP 'Boot\K[0-9A-Fa-f]{4}')
    # If nonzero
    if [[ -n "$bootnum" ]]; then
        echo Removing UEFI Shell at $bootnum
        sudo efibootmgr -b "$bootnum" -B &> /dev/null
    fi
done

echo "Registering UEFI boot entry at $DISK_DEV part $PART_NUM"
efibootmgr --create --disk "$DISK_DEV" --part "$PART_NUM" \
  --label "UEFI Shell" --loader '\EFI\Shell\Shell.efi'

echo "UEFI Shell boot entry created."
