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
- `cert_expired.der` - expired certificate file, can be enrolled with Secure Boot menu.
- `cert_root_ca.der` - Root CA certificate file, can be enrolled with Secure Boot menu.
- `hello-dasharo.efi` - program binary, can be executed with Secure Boot disabled.
- `hello-dasharo-signed-bad.efi` - program binary signed with some other certificate.
- `hello-dasharo-signed-good.efi` - program binary signed with `cert_good.der`.
- `hello-dasharo-signed-expired.efi` - program binary signed with `cert_expired.der`.
- `hello-dasharo-signed-intermediate.efi` - program binary signed with `cert_intermediate.der`.

**Note:** The expired certificate is included for completeness. Per UEFI spec, firmware is not required to reject images signed with expired certificates (in the form that the script generates them), making them currently not viable for testing. See: https://github.com/Dasharo/dasharo-issues/issues/1863.

For more information on available Makefile targets, please run `make help`.
