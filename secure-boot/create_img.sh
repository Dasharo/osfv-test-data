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
IMAGE_SIZE_MEGABYTES=100
SECTOR_SIZE_BYTES=512
PARTITION_OFFSET_SECTORS=2048

# do the math
IMAGE_SIZE_SECTORS=$((($IMAGE_SIZE_MEGABYTES*1024*1024)/$SECTOR_SIZE_BYTES))
PARTITION_OFFSET_BYTES=$(($PARTITION_OFFSET_SECTORS * $SECTOR_SIZE_BYTES))
echo Partition offset bytes: $PARTITION_OFFSET_BYTES

# Step 1: Create blank image
echo "Creating blank image..."
rm -f $IMAGE_FILE
dd if=/dev/zero of=$IMAGE_FILE bs=$SECTOR_SIZE_BYTES count=$IMAGE_SIZE_SECTORS > /dev/null 2>&1
error_check "Cannot create empty image file to store created certs and EFI files"

# Step2: Create partition table and partition entry
parted -s $IMAGE_FILE mklabel msdos mkpart primary fat32 $((PARTITION_OFFSET_SECTORS))s $(($IMAGE_SIZE_SECTORS-1))s

# Step 3: Create FAT32 in the partition and name it
mkfs.fat -F 32 -n $IMAGELABEL --offset $PARTITION_OFFSET_SECTORS $IMAGE_FILE $((($IMAGE_SIZE_SECTORS-$PARTITION_OFFSET_SECTORS)*$SECTOR_SIZE_BYTES/1024))
error_check "Cannot create FAT32 labeled: $IMAGELABEL"

# Step 4: Copy all files under FILES_DIR directory
echo "Copying files to image..."
mcopy -i $IMAGE_FILE@@$PARTITION_OFFSET_BYTES $FILES_DIR/* ::
error_check "Cannot copy files to image"

echo
echo $IMAGE_FILE contains:
mdir -i $IMAGE_FILE@@$PARTITION_OFFSET_BYTES ::

echo "Image creation and setup completed successfully."
