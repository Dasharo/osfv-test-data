## Hello, Dasharo Universe! - Secure Boot test program
An UEFI hello-world program, but with intentionally-added delays: pre- and post;
output to capture in tests: `UEFI Hello, Dasharo Universe!`

Build prerequisites for Fedora:
- mingw64-gcc
- openssl
- sbsigntools

Installation of mingw64-gcc compiler, or any other required package on Fedora:
`sudo dnf install mingw64-gcc`

Building `dist/` sub-directory, containing complete set of files for BAD_INFLUE Secure Boot USB stick:
`make clean && make dist`

List of files created in `dist/` sub-directory:
- `cert_fake.der` - fake certificate file with bad contents.
- `cert_good.der` - proper certificate file, can be enrolled with Secure Boot menu.
- `hello-dasharo.efi` - unsigned program binary, can be executed with Secure Boot disabled.
- `hello-dasharo-signed-bad.efi` - program binary signed with some other certificate.
- `hello-dasharo-signed-good.efi` - program binary signed with `cert_good.der`.

For more information on available Makefile targets, please run `make help`.
