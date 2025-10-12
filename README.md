# v86-buildroot
Buildroot customized for v86 emulator

Features:

* Top-level Makefile for simple, reproducable builds
* Out-of-tree build, the source tree of buildroot remains unmodified
* Customized for the [v86 emulator](https://github.com/copy/v86/tree/master)

## Installation instructions

Change the current working directory to your local working copy of this repository, then download and unpack the buildroot source tree:

```bash
# change CWD to this repository
cd v86-buildroot

# download and unpack buildroot 2024.05.2 into ./buildroot
curl -LO https://buildroot.org/downloads/buildroot-2024.05.2.tar.gz
mkdir buildroot
tar xfz buildroot-2024.05.2.tar.gz -C buildroot --strip-components=1
```

## Build instructions

First, define shell environment variables (needed once per terminal session):

```bash
source set_env.sh
```

Use `make help` for top-level Makefile commands, examples:

```bash
# optional, cleanup all previous build artifacts
make clean

# configure buildroot, required once after fresh installation or make clean
make buildroot-defconfig

# compile and link buildroot into build/v86/images/bzImage
make all
```

## Details

### Configuring buildroot and linux

To change the configuration of buildroot or linux use:

* `make buildroot-menuconfig`
* `make linux-menuconfig`

To save configurations use:

* `make buildroot-saveconfig`
* `make linux-savedefconfig`

### Implementation

* the board name used for Buildroot is **`v86`** (stored in `ACTIVE_PROJECT` in the top-level Makefile)
* the Buildroot `.config` file is therefore `configs/v86_defconfig`, it defines:
  * the Linux `.config` file as `board/v86/linux.config`
  * the root file system overlay as the tree below `board/v86/rootfs_overlay/`
* files `external.desc`, `Config.in` and `external.mk` are required by buildroot for an out-of-tree build

## Links

* [The Buildroot user manual](https://buildroot.org/downloads/manual/manual.html)
* [Setting-up Buildroot Out of Tree Folder Structure](https://eerdemsimsek.medium.com/setting-up-buildroot-out-of-tree-folder-structure-for-raspberry-pi-4b-fbd9765c0206)
