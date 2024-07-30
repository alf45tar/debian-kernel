FROM debian:bookworm AS deb-src
COPY <<"EOF" /etc/apt/sources.list
deb http://deb.debian.org/debian bookworm main
deb-src http://deb.debian.org/debian bookworm main

deb http://deb.debian.org/debian-security/ bookworm-security main
deb-src http://deb.debian.org/debian-security/ bookworm-security main

deb http://deb.debian.org/debian bookworm-updates main
deb-src http://deb.debian.org/debian bookworm-updates main
EOF

FROM deb-src AS install-dependency
RUN <<"EOF"
apt-get update
apt-get install -y wget fakeroot git kernel-wedge quilt ccache flex bison libssl-dev dh-exec rsync libelf-dev bc crossbuild-essential-armhf python3-jinja2 libncurses-dev
EOF

FROM install-dependency AS download-kernel
RUN <<"EOF"
cd /root
wget https://deb.debian.org/debian/pool/main/l/linux/linux_6.1.99.orig.tar.xz
EOF

FROM download-kernel AS clone-git
RUN <<"EOF"
git clone -n https://salsa.debian.org/kernel-team/linux.git debian-kernel
cd debian-kernel
git checkout bookworm
cd ..
EOF

FROM clone-git AS crossbuild-script
COPY <<"EOF" /root/crossbuild
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

# Add the missing config for enable leds
echo "CONFIG_GPIO_74X164=m" >> debian/config/config

fakeroot make -f debian/rules source

# Setup the build environment for a particular architecture, feature set, and flavour. 
fakeroot make -f debian/rules.gen setup_${ARCH}_${FEATURESET}_${FLAVOUR}

# Builds the architecture-specific binary package for the specified architecture, feature set, and flavour.
# It compiles the source code into binaries and packages them into a Debian package file.
fakeroot make -f debian/rules.gen binary-arch_${ARCH}_${FEATURESET}_${FLAVOUR}

cd ..
EOF
RUN chmod 755 /root/crossbuild
