#!/usr/bin/env bash

# Various setup actions after cloning this repo to fully prepare data for
# testing

git config annex.private true
git annex init
git annex pull

# dts
if pushd dts; then
  gzip -cdk dts-base-image-v2.1.3.wic.gz > dts-base-image-v2.1.3.wic
  popd
fi

