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
IMAGE_FILE="sb_test_data.img"
# 34 megabytes is minimal image size to avoid mkfs.fat complaints on FAT32 creation
IMAGE_SIZE_MEGABYTES=34
SECTOR_SIZE_BYTES=512
PARTTION_OFFSET_SECTORS=2048

# do the math
IMAGE_SIZE_SECTORS=$((($IMAGE_SIZE_MEGABYTES*1024*1024)/$SECTOR_SIZE_BYTES))
OFFSET_BYTES=$(($PARTTION_OFFSET_SECTORS * $SECTOR_SIZE_BYTES))
echo Partition offset bytes: $OFFSET_BYTES

# Step 1: Create blank image
echo "Creating blank image..."
rm -f $IMAGE_FILE
dd if=/dev/zero of=$IMAGE_FILE bs=$SECTOR_SIZE_BYTES count=$IMAGE_SIZE_SECTORS > /dev/null 2>&1
error_check "Cannot create empty image file to store created certs and EFI files"

# Step2: Create partition table and partition entry
parted -s $IMAGE_FILE mklabel msdos mkpart primary fat32 $((PARTTION_OFFSET_SECTORS))s $(($IMAGE_SIZE_SECTORS-1))s

# Step 3: Attach loop device to created partition
LOOPDEV=$(sudo losetup --offset $OFFSET_BYTES --show --find $IMAGE_FILE)
echo $LOOPDEV
MOUNTDIR=$(mktemp -d)

# Step 4: Create FAT32 and name it
sudo mkfs.fat -F 32 -n $IMAGELABEL $LOOPDEV
error_check "Cannot create FAT32 labeled: $IMAGELABEL"

# Step 5: Mount it in tmp dir
MOUNTDIR=$(mktemp -d)
error_check "Cannot create temporary mount directory"
sudo mount $LOOPDEV $MOUNTDIR
error_check "Cannot mount FAT32 partition"

# Step 6: Copy all files under FILES_DIR directory
echo "Copying files to image..."
if [ -d "$FILES_DIR" ]; then
    sudo cp -v -r $FILES_DIR/* $MOUNTDIR
    error_check "Cannot copy files to image"
    sudo sync
else
    echo "Warning: $FILES_DIR does not exist or is not a directory"
fi

echo
echo  $MOUNTDIR contains:
ls -l $MOUNTDIR

# Step 7: Unmount
echo "Unmounting and cleaning up..."
sudo umount $MOUNTDIR
error_check "Cannot unmount partition"

sudo losetup -d $LOOPDEV
error_check "Cannot detach loop device"

rmdir $MOUNTDIR

echo "Image creation and setup completed successfully."
