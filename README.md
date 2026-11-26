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

To build or publish files, also install [Task](https://taskfile.dev/installation/)
and Docker. The tasks run in the `git.3mdeb.com/dasharo/osfv-test-data-ci`
image, log in to pull it, with your Gitea username and a token with package read
access:

```bash
docker login git.3mdeb.com
```

Without access to the package, build the image locally from `.ci/Dockerfile`,
the tasks then use the local copy:

```bash
task image:build
```

We manage this repo by uploading large files to the 3mdeb FTP, with the tasks
described below. Where each file comes from, a build procedure or an external
reference (e.g. release mirror for ISO of particular Linux distro), is kept in
the `Makefile` of its directory. We do not use
[remote in git-annex](https://git-annex.branchable.com/special_remotes/) right now, we
rely on the FTP URLs registered by the tasks, with the URLs of the Makefiles as a
fallback. It may change in the future.

## Setup this repo

* After cloning, execute following to finalize test data setup:

```bash
make
```

It fetches every annexed file, and builds those the annex cannot fetch with the
rules of their directory's `Makefile`. With Task installed, `task setup` does
the same.

## Build and publish

```bash
task build DIR=secure-boot
task publish DIR=iso
```

`task build` rebuilds the files of a directory locally, all of them without
`DIR`. `task publish` also uploads them and pushes `master`, it needs
`FTP_DOMAIN`, `FTP_LOGIN` and `FTP_PASSWORD` in the environment, and
`FTP_REMOTE_DIR_PREFIX` if your FTP account needs one.

## Common actions

* Add or update a file: put it in its directory, or add a rule that builds or
  downloads it, list it in `ARTIFACTS` of that directory's `Makefile`, commit
  the Makefile and publish. A file that is replaced must be removed in the same
  commit, `task publish` fails on annexed files missing from `ARTIFACTS`:

```bash
git rm iso/TinyCore-15.0.iso
git add iso/Makefile
git commit -m "iso: replace TinyCore-15.0.iso with TinyCore-16.0.iso"
task publish DIR=iso
```

* Delete file permanently - use with caution:

```bash
git annex drop --force FILE_NAME
git annex whereis FILE_NAME                 # list of all copies known by annex
git annex drop --force FILE_NAME --from web # execute this line for each repository listed, web is one to use with http(s) links
rm FILE_NAME
git annex sync
```

* Remove a clone, git-annex makes its objects read-only:

```bash
chmod -R u+w osfv-test-data && rm -rf osfv-test-data
```
