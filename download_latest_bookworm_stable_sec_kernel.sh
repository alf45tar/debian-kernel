#!/bin/bash

# Function to get the latest stable-sec kernel version for Bookworm
get_latest_bookworm_stable_sec_kernel_version() {
  wget -qO- https://deb.debian.org/debian-security/dists/bookworm-security/main/source/Sources.xz | \
  unxz | \
  awk '/^Package: linux$/,/^$/ {if ($1 == "Version:") print $2}' | \
  grep -E '^[0-9]+\.[0-9]+\.[0-9]+-[0-9]+$' | \
  sort -V | tail -1 | \
  sed 's/-.*//'
}

# Get the latest stable-sec kernel version
latest_kernel_version=$(get_latest_bookworm_stable_sec_kernel_version)

if [ -z "$latest_kernel_version" ]; then
  echo "Failed to retrieve the latest stable-sec kernel version for Bookworm."
  exit 1
fi

echo "Latest stable-sec kernel version for Bookworm: $latest_kernel_version"

# Define the download URL
kernel_url="https://deb.debian.org/debian/pool/main/l/linux/linux_${latest_kernel_version}.orig.tar.xz"

# Download the kernel tarball
wget -O linux_${latest_kernel_version}.orig.tar.xz "$kernel_url"

if [ $? -eq 0 ]; then
  echo "Downloaded linux_${latest_kernel_version}.orig.tar.xz successfully."
else
  echo "Failed to download linux_${latest_kernel_version}.orig.tar.xz."
  exit 1
fi
