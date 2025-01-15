# osfv-test-data

This repository contains various files used during Dasharo regression testing
process.

This is an integral part of the
[OSFV framework](https://github.com/Dasharo/open-source-firmware-validation).

The goal of this repo is to minimize the process of downloading external files
from various sources during test exection. Instead, they are stored in a single
place, under version control, tighly coupled with the specific commit of test
environment via git submodule.

This repository uses [git lfs](https://git-lfs.com/) for versioning large
files. Make sure to install it first.
