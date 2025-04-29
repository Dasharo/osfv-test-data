## BAD_INFLUE - Secure Boot test image

### sb_test_data.img features:
* Single FAT32 partition, labeled BAD_INFLUE, on MBR disk image
* Contains files from `../hello-dasharo/dist` directory
* Can be safely transferred with dd command to USB stick

### How to generate image:
1. Go to `../hello-dasharo/` directory.
2. Refer to `README.md` file located there on how to prepare contents od `dist/` sub-directory.
3. Go back here - `secure-boot/`
4. Run `create_img.sh`, observe the output, especially list of files transferred to the image.
5. Script execution should finish with `Image creation and setup completed successfully.`

### How to transfer image to USB stick:
1. Use `lsblk` command to identify target USB stick device node and any active mount points.
2. Use `sudo dd of=./sb_test_data.img if=/dev/X bs=1M status=progress` where X is identified target device node.
3. Use `sync` command to finalize write operations before stick removal.
