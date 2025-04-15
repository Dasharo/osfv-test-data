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
IMAGE_FILE=sb_test_data.img
IMAGE_SIZE_MEGABYTES=4

IMAGE_SIZE_SECTORS=$((($IMAGE_SIZE_MEGABYTES*1024*1024)/512))

# Step 1: Create blank image
echo "Creating blank image..."
rm -f $IMAGE_FILE
dd if=/dev/zero of=$IMAGE_FILE bs=512 count=$IMAGE_SIZE_SECTORS > /dev/null 2>&1
error_check "Cannot create empty image file to store created certs and EFI files"

# Step2: Create partition table and partition entry
parted -s $IMAGE_FILE mklabel msdos mkpart primary ext2 2048s $(($IMAGE_SIZE_SECTORS-1))s

# Step 3: Create ext2fs and name it
mkfs -t ext2 -E offset=$((2048 * 512)) -L $IMAGELABEL $IMAGE_FILE 1M
#error_check "Cannot create ext2fs labeled: $IMAGELABEL"

# Step 4: Mount it in tmp dir via losetup
LOOPDEV=$(sudo losetup --show -Pf $IMAGE_FILE)
MOUNTDIR=$(mktemp -d)
error_check "Cannot create temporary mount directory"
sudo mount "${LOOPDEV}p1" $MOUNTDIR

# Step 5: Copy all files under files/ directory
echo "Copying files to image..."
if [ -d "$FILES_DIR" ]; then
    sudo cp -r $FILES_DIR/* $MOUNTDIR
    error_check "Cannot copy files to image"
     sudo sync
else
    echo "Warning: $FILES_DIR does not exist or is not a directory"
fi

# Step 6: Unmount
echo "Unmounting and cleaning up..."
sudo umount $MOUNTDIR
error_check "Cannot unmount image"

sudo losetup -d $LOOPDEV
error_check "Cannot detach loop device"

rmdir $MOUNTDIR

echo "Image creation and setup completed successfully."
