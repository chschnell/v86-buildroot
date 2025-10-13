#
# Makefile
# v86-buildroot top-level Makefile
#
# Based off: https://eerdemsimsek.medium.com/setting-up-buildroot-out-of-tree-folder-structure-for-raspberry-pi-4b-fbd9765c0206
#

# Top-level public make variable definitions (visible to recursive invocations of make)
export BR2_EXTERNAL := $(CURDIR)
export ACTIVE_PROJECT ?= v86

# Build Directory
BUILDROOT_BUILD_DIR := build/$(ACTIVE_PROJECT)

# Wrapper for recursive MAKE invocations
MAKE_BUILDROOT = $(MAKE) -C buildroot O=../$(BUILDROOT_BUILD_DIR)

# Check that ACTIVE_PROJECT is set and that config file and board directory exist
check-project:
	@echo "Active Project: '$(ACTIVE_PROJECT)'"
	@if [ -z "$(ACTIVE_PROJECT)" ]; then \
	 echo "Error: ACTIVE_PROJECT environment variable is not set."; \
	 exit 1; \
	fi
	@if [ ! -f "configs/$(ACTIVE_PROJECT)_defconfig" ]; then \
	 echo "Error: file configs/$(ACTIVE_PROJECT)_defconfig not found."; \
	 exit 1; \
	fi
	@if [ ! -d "board/$(ACTIVE_PROJECT)" ]; then \
	 echo "Error: directory board/$(ACTIVE_PROJECT) not found."; \
	 exit 1; \
	fi

# Build Targets
all: check-project buildroot-build

list-defconfigs: check-project
	$(MAKE_BUILDROOT) list-defconfigs

# Buildroot Targets
buildroot-defconfig: check-project
	$(MAKE_BUILDROOT) $(ACTIVE_PROJECT)_defconfig

buildroot-menuconfig: check-project
	$(MAKE_BUILDROOT) menuconfig

buildroot-saveconfig: check-project
	$(MAKE_BUILDROOT) savedefconfig

buildroot-build: check-project
	$(MAKE_BUILDROOT)

buildroot-clean: check-project
	$(MAKE_BUILDROOT) clean

buildroot-dirclean: check-project
	$(MAKE_BUILDROOT) distclean

# Linux kernel targets
linux-menuconfig: check-project
	$(MAKE_BUILDROOT) linux-menuconfig

linux-saveconfig: check-project
	$(MAKE_BUILDROOT) linux-savedefconfig
	cp $(BUILDROOT_BUILD_DIR)/build/linux-6.8.12/defconfig board/$(ACTIVE_PROJECT)/linux.config

linux-rebuild: check-project
	$(MAKE_BUILDROOT) linux-rebuild

# Busybox targets
busybox-menuconfig: check-project
	$(MAKE_BUILDROOT) busybox-menuconfig

busybox-saveconfig: check-project
	$(MAKE_BUILDROOT) busybox-update-config

busybox-rebuild: check-project
	$(MAKE_BUILDROOT) busybox-rebuild

# bootstrap and release special targets
buildroot-2024.05.2.tar.gz:
	curl -LO https://buildroot.org/downloads/buildroot-2024.05.2.tar.gz

bootstrap: buildroot-2024.05.2.tar.gz
	@if [ -d buildroot ]; then \
	 echo "Error: Directory buildroot already exists."; \
	 exit 1; \
	fi
	mkdir buildroot
	tar xfz buildroot-2024.05.2.tar.gz -C buildroot --strip-components=1

release: check-project
	@if [ -z "$(RELEASE_VER)" ]; then \
	 echo "Error: RELEASE_VER environment variable is not set, example: \"1.0.0\"."; \
	 exit 1; \
	fi
	tar -C build/v86/images --transform='flags=r;s|bzImage|buildroot-bzimage68_v86.bin|' -cjf v86-buildroot-$(RELEASE_VER).tar.bz2 bzImage rootfs.cpio rootfs.tar

# --- Dynamic Package Targets (currently unused) ---

# Find all package makefiles in the external tree
PACKAGE_MK_FILES := $(wildcard $(BR2_EXTERNAL)/package/*/*.mk)

# Extract package names from the makefile paths
PACKAGE_NAMES := $(basename $(notdir $(PACKAGE_MK_FILES)))

# Generate targets for each package
$(foreach pkg,$(PACKAGE_NAMES),\
	$(eval buildroot-$(pkg)-build: check-project ; $(MAKE_BUILDROOT) $(pkg)))
$(foreach pkg,$(PACKAGE_NAMES),\
	$(eval buildroot-$(pkg)-rebuild: check-project ; $(MAKE_BUILDROOT) $(pkg)-rebuild))
$(foreach pkg,$(PACKAGE_NAMES),\
	$(eval buildroot-$(pkg)-clean: check-project ; $(MAKE_BUILDROOT) $(pkg)-clean))
$(foreach pkg,$(PACKAGE_NAMES),\
	$(eval buildroot-$(pkg)-dirclean: check-project ; $(MAKE_BUILDROOT) $(pkg)-dirclean))

# Combined Targets
clean: check-project buildroot-clean
	@echo "Cleaning project..." # Informative message

dirclean: check-project buildroot-dirclean
	@echo "Distcleaning project..." # Informative message

rebuild: dirclean buildroot-build
	@echo "Rebuilding project..."

# Help Target
help:
	@echo "Makefile for Buildroot project"
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  all                  : Build Buildroot, including all enabled packages"
	@echo "  buildroot-defconfig  : Initialize Buildroot from configs/$(ACTIVE_PROJECT)_defconfig"
	@echo "  buildroot-menuconfig : Edit Buildroot configuration"
	@echo "  buildroot-saveconfig : Save Buildroot configuration to configs/$(ACTIVE_PROJECT)_defconfig"
	@echo "  buildroot-build      : Build Buildroot"
	@echo "  buildroot-clean      : Clean Buildroot build artifacts"
	@echo "  buildroot-dirclean   : Distclean Buildroot (removes downloads and build dirs)"
	@echo "  linux-menuconfig     : Edit Linux configuration"
	@echo "  linux-saveconfig     : Save Linux configuration to board/$(ACTIVE_PROJECT)/linux.config"
	@echo "  linux-rebuild        : Rebuild Linux"
	@echo "  busybox-menuconfig   : Edit Busybox configuration"
	@echo "  busybox-saveconfig   : Save Busybox configuration to board/$(ACTIVE_PROJECT)/busybox.config"
	@echo "  busybox-rebuild      : Rebuild Busybox"
	@echo ""
	@echo "Package-Specific Targets (Dynamically Generated):"
	@$(foreach pkg,$(PACKAGE_NAMES), echo "    buildroot-$(pkg)-build    : Build package '$(pkg)'";)
	@$(foreach pkg,$(PACKAGE_NAMES), echo "    buildroot-$(pkg)-rebuild  : Rebuild package '$(pkg)' and its dependencies";)
	@$(foreach pkg,$(PACKAGE_NAMES), echo "    buildroot-$(pkg)-clean    : Clean package '$(pkg)' build artifacts";)
	@$(foreach pkg,$(PACKAGE_NAMES), echo "    buildroot-$(pkg)-dirclean : Distclean package '$(pkg)'";)
	@echo ""
	@echo "Special Targets:"
	@echo "  bootstrap            : Download buildroot source archive and extract into buildroot/"
	@echo "  release              : Create release archive, needs environment variable RELEASE_VER"
	@echo "  clean                : Clean the entire project (same as buildroot-clean)"
	@echo "  dirclean             : Distclean the entire project (same as buildroot-dirclean)"
	@echo "  rebuild              : Perform a dirclean followed by a full build"
	@echo "  list-defconfigs      : Show the list of all Buildroot configurations"
	@echo "  help                 : Display this help message"

.PHONY: check-project \
	buildroot-defconfig buildroot-menuconfig buildroot-saveconfig \
	buildroot-build buildroot-clean buildroot-dirclean \
	linux-menuconfig linux-saveconfig linux-rebuild \
	busybox-menuconfig busybox-saveconfig busybox-rebuild \
	bootstrap release list-defconfigs \
	$(foreach pkg,$(PACKAGE_NAMES),buildroot-$(pkg)-build buildroot-$(pkg)-rebuild buildroot-$(pkg)-clean buildroot-$(pkg)-dirclean) \
	 clean dirclean rebuild help
