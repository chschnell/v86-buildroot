# v86-buildroot
[Buildroot](https://buildroot.org/) customized for the [v86 emulator](https://github.com/copy/v86/tree/master).

Features:

* Top-level Makefile for simple, reproducible builds
* Keeps Buildroot source tree, v86 customizations and build artifacts in separate directories
* Out-of-tree build, the Buildroot source tree always remains unmodified
* Supported v86 features include: serial0, virtio-console, virtio-net, fda, fdb, hda, hdb and cdrom
* Supports Unicode (intended for use case serial connection with XTerm.js)

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

### Configuring Buildroot, Linux and Busybox

To edit the configurations of Buildroot, Linux or Busybox use:

```bash
make buildroot-menuconfig
make linux-menuconfig
make busybox-menuconfig
```

To save configurations use:

```bash
make buildroot-saveconfig
make linux-saveconfig
make busybox-saveconfig
```

### Implementation

The v86-buildroot top-level Makefile invokes the Buildroot Makefile such that all configuration elements are read from directories `configs/` and `board/`, and all build artifacts are written to `build/`. Buildroot's *br2-external mechanism* is used for this build mode, see chapter ["9.2. Keeping customizations outside of Buildroot"](https://buildroot.org/downloads/manual/manual.html#outside-br-custom) in the Buildroot documentation for details.

The Buildroot board name defined in the top-level Makefile is `v86` (stored in variable `ACTIVE_PROJECT`).

Directory layout overview (after running `make buildroot-defconfig`):

```
v86-buildroot
├── board
│   └── v86
│       ├── busybox.config  // Busybox .config
│       ├── linux.config    // Linux .config
│       └── rootfs_overlay  // Overlay file system root
│           └── ...
├── build                   // Build directory (created by Makefile)
│   └── v86
│       └── ...
├── buildroot               // Buildroot source directory (created by Makefile)
│   └── ...
├── configs
│   └── v86_defconfig       // Buildroot .config
├── Config.in               // Buildroot out-of-tree build requirement (empty)
├── external.desc           // Buildroot out-of-tree build description file
├── external.mk             // Buildroot out-of-tree build requirement (empty)
├── LICENSE
├── Makefile                // Top-level Makefile
└── README.md
```

## Links

* [The Buildroot user manual](https://buildroot.org/downloads/manual/manual.html)
* [Setting-up Buildroot Out of Tree Folder Structure](https://eerdemsimsek.medium.com/setting-up-buildroot-out-of-tree-folder-structure-for-raspberry-pi-4b-fbd9765c0206) (root of the top-level Makefile)
* [Config used for buildroot image](https://github.com/copy/v86/issues/725) (root of the v86 customizations)
