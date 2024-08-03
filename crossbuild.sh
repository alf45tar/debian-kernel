#!/bin/bash

# This triplet is defined in
# https://salsa.debian.org/kernel-team/linux/tree/master/debian/config/armhf/
ARCH=armhf
FEATURESET=none
FLAVOUR=armmp-lpae

cd /root/debian-kernel

export $(dpkg-architecture -a$ARCH)
export PATH=/usr/lib/ccache:$PATH
# Build profiles is from: https://salsa.debian.org/kernel-team/linux/blob/master/debian/README.source
export DEB_BUILD_PROFILES="cross nopython nodoc pkg.linux.notools"
# Enable build in parallel
export MAKEFLAGS="-j$(($(nproc)*2))"
# Disable -dbg (debug) package is only possible when distribution="UNRELEASED" in debian/changelog
export DEBIAN_KERNEL_DISABLE_DEBUG=
[ "$(dpkg-parsechangelog --show-field Distribution)" = "UNRELEASED" ] &&
  export DEBIAN_KERNEL_DISABLE_DEBUG=yes

# Remove any compiled binaries, temporary files, and other generated artifacts, preparing the directory for a fresh build.
fakeroot make -f debian/rules clean

# Unpack the original tarball ../linux_X.Y.Z.orig.tar.xz) in ../orig
fakeroot make -f debian/rules orig

# Add the missing config for enable leds and disable debug
../configure_kernel_options.sh

# Patch the kernel
patch -p1 < ../0001-ledtrig-sata-mv.patch

# Prepare the source package for a Debian package
fakeroot make -f debian/rules source

# Setup the build environment for a particular architecture, feature set, and flavour. 
fakeroot make -f debian/rules.gen setup_${ARCH}_${FEATURESET}_${FLAVOUR}

# Builds the architecture-specific binary package for the specified architecture, feature set, and flavour.
# It compiles the source code into binaries and packages them into a Debian package file.
fakeroot make -f debian/rules.gen binary-arch_${ARCH}_${FEATURESET}_${FLAVOUR}
