# Building a Linux Kernel Using GitHub Actions

GitHub Actions supports Ubuntu Linux on the AMD64 architecture. However, I need to build a Debian Bookworm kernel for the ARMHF architecture, modify the standard configuration, and apply an additional patch.

The solution is to use a Docker container and wait a couple of hours for the final result.
