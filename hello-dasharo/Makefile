all: hello-dasharo.efi

CC = x86_64-w64-mingw32-gcc \
	-Wl,--subsystem,10 \
	-e efi_main

CFLAGS = \
	-Wall -Wextra -Wpedantic \
	-mno-red-zone \
	-ffreestanding -nostdlib

hello-dasharo.efi: hello-dasharo.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -rf *.o
	rm -rf *~
	rm -rf hello-dasharo.efi
