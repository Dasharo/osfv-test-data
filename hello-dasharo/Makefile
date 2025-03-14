all: hello-dasharo.efi

.SILENT: help

help:
	echo "Supported targets:"
	echo " (none) or all - build hello_dasharo.efi"
	echo " sign - generate keys, certificates and signs hello_dasharo.efi"
	echo " dist - re-creates dist (distribution) directory"
	echo " clean - remove *.o & .efi from this directory"

CC = x86_64-w64-mingw32-gcc \
	-Wl,--subsystem,10 \
	-e efi_main

CFLAGS = \
	-Wall -Wextra -Wpedantic \
	-mno-red-zone \
	-ffreestanding -nostdlib

hello-dasharo.efi: hello-dasharo.c
	$(CC) $(CFLAGS) -o $@ $<

sign: hello-dasharo.efi
	cd signing; ./regene.sh
	sbsign --key signing/private-key-good.pem --cert signing/cert_good.pem \
	--output hello-dasharo-signed-good.efi $<
	sbsign --key signing/private-key-bad.pem --cert signing/cert_bad.pem \
	--output hello-dasharo-signed-bad.efi $<
dist: sign
	rm -rf $@
	mkdir $@
	cp hello-dasharo.efi ./$@/
	cp hello-dasharo-signed-good.efi ./$@/
	cp hello-dasharo-signed-bad.efi ./$@/
	cp ./signing/cert_good.der ./$@/

clean:
	rm -rf *.o
	rm -rf *~
	rm -rf *.efi
