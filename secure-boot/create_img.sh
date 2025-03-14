#!/usr/bin/env bash

# Function to check for errors
error_check() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

IMAGELABEL="BAD_INFLUE"
FILES_DIR="../hello-dasharo/dist"
IMAGE_FILE="sb_test_BAD_INFLUE.img"

# Step 1: Create blank image
echo "Creating blank image..."
dd if=/dev/zero of=$IMAGE_FILE bs=1M count=4 > /dev/null 2>&1
error_check "Cannot create empty image file to store created certs and EFI files"

mkfs.fat -F 12 $IMAGE_FILE -n $IMAGELABEL > /dev/null 2>&1
error_check "Cannot assign label: $IMAGELABEL"

# Step 2: Mount it in tmp dir via losetup
echo "Setting up loop device and mounting..."
LOOPDEV=$(sudo losetup --find --show $IMAGE_FILE)
error_check "Cannot set up loop device"

MOUNTDIR=$(mktemp -d)
error_check "Cannot create temporary mount directory"

sudo mount $LOOPDEV $MOUNTDIR
error_check "Cannot mount image file"

# Step 3: Copy all files under files/ directory
echo "Copying files to image..."
if [ -d "$FILES_DIR" ]; then
    sudo cp -r $FILES_DIR/* $MOUNTDIR
    error_check "Cannot copy files to image"
    sudo sync
else
    echo "Warning: $FILES_DIR does not exist or is not a directory"
fi

# Step 4: Unmount
echo "Unmounting and cleaning up..."
sudo umount $MOUNTDIR
error_check "Cannot unmount image"

sudo losetup -d $LOOPDEV
error_check "Cannot detach loop device"

rmdir $MOUNTDIR

echo "Image creation and setup completed successfully."
