#!/usr/bin/env bash

# Various setup actions after cloning this repo to fully prepare data for
# testing


# dts
if pushd dts; then
  gzip -cdk dts-base-image-v2.1.3.wic.gz > dts-base-image-v2.1.3.wic
  popd
fi

git annex unlock dasharo-driver/dasharo-acpi-dkms-0.9.1*

