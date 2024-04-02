## Using buildroot to cross-compile embedded linux systems

> Buildroot is a simple, efficient and easy-to-use tool to generate embedded Linux systems through cross-compilation.

Buildroot is a widely used tool for cross-compilation. It's quite easy to use
compared to alternatives like [yocto](https://www.yoctoproject.org/).
It takes care of bootstrapping a suitable toolchain with support for various
standard library implementations (glibc, musl, uClibc-ng). Most importantly
it can build rootfs from scratch including the necessary bootloaders.

In this lab we will be using mainline buildroot to build a bootable disk image
for Sipeed LP4A.
