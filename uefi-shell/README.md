# UEFI Shell application

Due to security concerns, UEFI Shell is no longer shipped with Dasharo
as built-in component. Instead, to keep usefulness of UEFI Shell, we
provide it on the OS drive, in the EFI partition, and add it to bootmanager.
This way, menu traversal to reach UEFI Shell does not change, instead we
have to install it as part of platform setup.

This subdirectory contains two scripts:
generate-shell-efi.sh - Builds edk2 ShellPkg and places resulting file as Shell.efi
deploy-shell-efi.sh - Takes Shell.efi as param, and installs it on a system
