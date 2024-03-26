## Prerequisites

The official linux distro for Lichee PI 4A is [revyos](https://wiki.sipeed.com/hardware/en/lichee/th1520/lpi4a/7_develop_revyos.html)

## Revyos image

Download a prebuilt system image from the manufacturer [here](https://wiki.sipeed.com/hardware/en/lichee/th1520/lpi4a/3_images.html).
Here's a direct [link](https://mega.nz/folder/phoQlBTZ#cZeQ3qZ__pDvP94PT3_bGA/file/k4Bg2BCD). Please choose the latest LPI4A_BASIC archive.
Mega has arbitrary restrictions on download size, so LPI4A_FULL is too large and you will get throttled.

### Distrobox for building inside ubuntu-22.04 container.

Distrobox is a tool for working inside OCI containers in your shell. Visit the [homepage](https://github.com/89luca89/distrobox/)
or the official [website](https://distrobox.it/). Follow the installation instructions for your distribution.

Excerpt from the official installation docs:

> If you like to live your life dangerously, or you want the latest release,
> you can trust \[the author of distrobox\] and simply run this in your terminal:

```bash
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
# or using wget
wget -qO- https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
```

After you've installed distrobox you can create a fresh `ubuntu-22.04` container with a
single command:

```bash
distrobox create --image ubuntu:22.04 --name ubuntu-22.04-revyos-sdk
```

When the command has finished downloading OCI container image you can enter it like so:

```bash
distrobox enter ubuntu-22.04-revyos-sdk
```

**All of the subsequent instructions assume you are working inside the newly created container.**
If you have any questions/problems please refer to the official [quick-start guide](https://distrobox.it/#quick-start).

### Build RevyOS QEMU

Vendor has implemented some custom RISC-V spec *extensions*, so in order to run binaries compiled for their system you will
need a build of custom QEMU.

#### Build instructions for `ubuntu-22.04`.

Install the build-time dependencies.

```bash
sudo apt install ninja-build python3-venv build-essential libglib2.0-dev flex bison libpixman-1-dev git fdisk file tsocks
```

Fetch the repository and compile it from source.

```bash
git clone https://github.com/revyos/qemu revyos-qemu
cd revyos-qemu
git submodule init
git submodule update --recursive
./configure --target-list=riscv64-softmmu,riscv64-linux-user --with-git='tsocks git'
make -j $(nproc)
sudo make install # This will install qemu-riscv64 and qemu-system-riscv64 inside the container
# Your host system will not be affected.
```
