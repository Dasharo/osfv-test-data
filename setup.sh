#!/usr/bin/env bash

# Various setup actions after cloning this repo to fully prepare data for
# testing


# dts
if pushd dts; then
  gzip -cdk dts-base-image-v2.1.3.wic.gz > dts-base-image-v2.1.3.wic
  popd
fi

#!/usr/bin/env bash
set -e

# Post-clone setup script

echo "Preparing Dasharo driver packages in annex..."

git annex addurl --fast \
  --file=dasharo-driver/dasharo-acpi-dkms-0.9.1.x86_64.rpm \
  https://github.com/Dasharo/dasharo-acpi-dkms/releases/download/v0.9.1/dasharo-acpi-dkms-0.9.1.x86_64.rpm

git annex addurl --fast \
  --file=dasharo-driver/dasharo-acpi-dkms-0.9.1_amd64.deb \
  https://github.com/Dasharo/dasharo-acpi-dkms/releases/download/v0.9.1/dasharo-acpi-dkms_0.9.1_amd64.deb


# Make sure annex content is present
echo "Fetching annex content..."
git annex get dasharo-driver/dasharo-acpi-dkms-0.9.1*
