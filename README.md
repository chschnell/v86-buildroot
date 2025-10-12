# v86-buildroot
Buildroot customized for the [v86 emulator](https://github.com/copy/v86/tree/master).

Features:

* Top-level Makefile for simple, reproducible builds
* Keeps Buildroot source tree, v86 customizations and build artifacts in separate directories
* Out-of-tree build, the Buildroot source tree always remains unmodified

## Installation instructions

Change the current working directory to your local working copy of this repository, then download and unpack the Buildroot source tree using:

```bash
make bootstrap
```

## Build instructions

Use `make help` for help about all top-level Makefile commands, examples:

```bash
# optional, cleanup all previous build artifacts
make clean

# configure Buildroot, required once after fresh installation or make clean
make buildroot-defconfig

# compile and link Buildroot into build/v86/images/bzImage
make all
```

## Details

### Configuring Buildroot and Linux

To change the configuration of Buildroot or Linux use:

```bash
make buildroot-menuconfig
make linux-menuconfig
```

To save configurations use:

```bash
make buildroot-saveconfig
make linux-savedefconfig
```

### Implementation

* directories:
  * buildroot source directory (created by `make bootstrap`): `buildroot/`
  * customization directories: `board/` and `configs/`
  * build directory (created by `make`): `build/`
* the Buildroot board name used is **`v86`** (stored in `ACTIVE_PROJECT` in the top-level Makefile)
* the Buildroot `.config` file is `configs/v86_defconfig`, it defines:
  * the Linux `.config` file as `board/v86/linux.config`
  * the Busybox `.config` file as `board/v86/busybox.config`
  * the root file system overlay as the tree below `board/v86/rootfs_overlay/`
* files `Config.in`, `external.desc` and `external.mk` are required by Buildroot for an out-of-tree build

## Links

* [The Buildroot user manual](https://buildroot.org/downloads/manual/manual.html)
* [Setting-up Buildroot Out of Tree Folder Structure](https://eerdemsimsek.medium.com/setting-up-buildroot-out-of-tree-folder-structure-for-raspberry-pi-4b-fbd9765c0206)
