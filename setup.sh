#!/usr/bin/env bash

# Various setup actions after cloning this repo to fully prepare data for
# testing

set -euo pipefail

git config annex.private true
git annex init
git annex pull

# An annex key keeps no file mode
chmod +x coreboot-tools/cbfstool coreboot-tools/cbmem coreboot-tools/flashrom

# dts
if pushd dts; then
  gzip -cdk dts-base-image-v2.1.3.wic.gz > dts-base-image-v2.1.3.wic
  popd
fi

