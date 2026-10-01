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
	cd signing; ./keygen.sh
	sbsign --key signing/private-key-good.pem --cert signing/cert_good.pem \
	--output hello-dasharo-signed-good.efi $<
	sbsign --key signing/private-key-bad.pem --cert signing/cert_bad.pem \
	--output hello-dasharo-signed-bad.efi $<
	sbsign --key signing/private-key-expired.pem --cert signing/cert_expired.pem \
	--output hello-dasharo-signed-expired.efi $<
	sbsign --key signing/private-key-leaf.pem \
		   --cert signing/cert_leaf.pem \
		   --addcert signing/cert_intermediate.pem \
		   --output hello-dasharo-signed-intermediate.efi $<
	rm -f hello-dasharo-signed-ts.efi
	osslsigncode sign -h sha256 \
		-key signing/private-key-ts.pem -certs signing/cert_ts.pem \
		-TSA-certs signing/cert_tsa.pem -TSA-key signing/private-key-tsa.pem \
		-TSA-time $$(cat signing/ts_sign_time.txt) \
		-in $< -out hello-dasharo-signed-ts.efi
	sbsign --key signing/private-key-ts.pem --cert signing/cert_ts.pem \
	--output hello-dasharo-signed-no-ts.efi $<

dist: sign
	rm -rf $@
	mkdir $@
	cp hello-dasharo.efi ./$@/
	cp hello-dasharo-signed-good.efi ./$@/
	cp hello-dasharo-signed-bad.efi ./$@/
	cp hello-dasharo-signed-expired.efi ./$@/
	cp hello-dasharo-signed-intermediate.efi ./$@/
	cp hello-dasharo-signed-ts.efi ./$@/
	cp hello-dasharo-signed-no-ts.efi ./$@/
	cp ./signing/cert_good.der ./$@/
	cp ./signing/cert_expired.der ./$@/
	cp ./signing/cert_root_ca.der ./$@/
	cp ./signing/cert_ts.der ./$@/
	cp ./signing/cert_tsa.der ./$@/
	cp hello-dasharo.efi ./$@/cert_fake.der

clean:
	rm -rf *.o
	rm -rf *~
	rm -rf *.efi
