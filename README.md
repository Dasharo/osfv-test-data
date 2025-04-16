# osfv-test-data

This repository contains various files used during Dasharo regression testing
process.

This is an integral part of the
[OSFV framework](https://github.com/Dasharo/open-source-firmware-validation).

The goal of this repo is to minimize the process of downloading external files
from various sources during test exection. Instead, they are stored in a single
place, under version control, tighly coupled with the specific commit of test
environment via git submodule.

This repository uses [git-annex](https://git-annex.branchable.com/) for
versioning large files. Make sure to install it first.

```bash
sudo dnf install git-annex
```

We manage this repo by first uploading large files **somewhere** (cloud, HTTP
hosting), or using external references (e.g. release mirror for ISO of
particular Linux distro). Then, we track such file in this repo via `git annex`.
We do not use
[remote in git-annex](https://git-annex.branchable.com/special_remotes/) right now, we
rely on URLs prepare beforehand. It may change in the future.

## Setup this repo

* After cloning, execute following to finalize test data setup:

```bash
git annex pull
./setup.sh
```

## Common actions

* Add new file from URL:

```bash
git annex addurl https://github.com/Dasharo/meta-dts/releases/download/v2.1.3/dts-base-image-v2.1.3.wic.gz --file=dts/dts-base-image-v2.1.3.wic.gz
git annex addurl http://www.tinycorelinux.net/15.x/x86/release/TinyCore-15.0.iso --file iso/TinyCore-15.0.iso
```
* Delete file permanently - use with caution:

```bash
git annex drop --force FILE_NAME
git annex whereis FILE_NAME                 # list of all copies known by annex
git annex drop --force FILE_NAME --from web # execute this line for each repository listed, web is one to use with http(s) links
rm FILE_NAME
git annex sync
```
