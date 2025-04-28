
### Welcome to Hello Dasharo Universe!
An UEFI hello-world program, but with delay, pre- and post.

Build prerequisites, for Fedora distrubution:
- mingw64-gcc
- openssl
- sbsigntools

Installation of mingw64-gcc compiler packages:
`sudo dnf install mingw64-gcc`

Building dist directory, containing complete set of files for BAD_INFLUE SecureBoot USB stick:
`make clean && make dist`

For more information on available Makefile targets:
`make help`

