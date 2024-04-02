## Cross compiling a system for RISC-V with Buildroot

### Getting buildroot

First off you will need to install dependencies and download mainline buildroot.

```bash
wget https://buildroot.org/downloads/buildroot-2024.02.1.tar.gz
tar -xzvf buildroot-2024.02.1.tar.gz
cd buildroot-2024.02.1/
sudo apt install libncurses-dev file cpio libssl-dev fdisk dosfstools cmake ccache build-essential
```

Create a `defconfig` file with the following command. This defines minimal set
of buildroot options.

```bash
echo 'BR2_riscv=y
BR2_RISCV_ISA_RVC
BR2_TOOLCHAIN_BUILDROOT_MUSL=y
BR2_PACKAGE_HOST_LINUX_HEADERS_CUSTOM_5_10=y
BR2_GCC_VERSION_13_X=y
BR2_LINUX_KERNEL=y
BR2_LINUX_KERNEL_CUSTOM_GIT=y
BR2_LINUX_KERNEL_CUSTOM_REPO_URL="https://github.com/revyos/thead-kernel"
BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION="lpi4a"
BR2_LINUX_KERNEL_DEFCONFIG="revyos"
BR2_LINUX_KERNEL_DTS_SUPPORT=y
BR2_LINUX_KERNEL_INTREE_DTS_NAME="thead/light-lpi4a"
BR2_LINUX_KERNEL_NEEDS_HOST_PAHOLE=y
BR2_TARGET_ROOTFS_EXT2=y
BR2_TARGET_ROOTFS_EXT2_4=y
BR2_TARGET_ROOTFS_EXT2_SIZE="512M"
BR2_TARGET_ROOTFS_INITRAMFS=y
# BR2_TARGET_ROOTFS_TAR is not set
BR2_TARGET_OPENSBI=y
BR2_TARGET_OPENSBI_CUSTOM_GIT=y
BR2_TARGET_OPENSBI_CUSTOM_REPO_URL="https://github.com/revyos/opensbi"
BR2_TARGET_OPENSBI_CUSTOM_REPO_VERSION="th1520-v1.4"
BR2_TARGET_OPENSBI_PLAT="generic"
# BR2_TARGET_OPENSBI_INSTALL_JUMP_IMG is not set
BR2_TARGET_UBOOT=y
BR2_TARGET_UBOOT_BUILD_SYSTEM_KCONFIG=y
BR2_TARGET_UBOOT_CUSTOM_GIT=y
BR2_TARGET_UBOOT_CUSTOM_REPO_URL="https://github.com/revyos/thead-u-boot"
BR2_TARGET_UBOOT_CUSTOM_REPO_VERSION="th1520"
BR2_TARGET_UBOOT_BOARD_DEFCONFIG="light_lpi4a"
BR2_TARGET_UBOOT_NEEDS_OPENSBI=y
BR2_TARGET_UBOOT_SPL=y
BR2_PACKAGE_HOST_UBOOT_TOOLS=y' > defconfig
```

Then create `.config` via `make`:

```
make defconfig BR2_DEFCONFIG=./defconfig
```

Now the only thing left to do is launch `make` and wait till completion.
Depending on the machine this might take a while.

Next you will need to fetch vendor-provided binary blobs (boot firmware):

```
wget https://github.com/revyos/th1520-boot-firmware/archive/refs/tags/20240127+sdk1.4.2.tar.gz
tar -xzvf 20240127+sdk1.4.2.tar.gz
```

Now we can create out boot filesystem partition:

```
dd if=/dev/zero of=output/images/bootfs.ext4 bs=4M count=32 && sync
sudo mkfs.ext4 output/images/bootfs.ext4
sudo mkdir /mnt/boot -p
sudo mount output/images/bootfs.ext4 /mnt/boot
sudo mkdir /mnt/boot/extlinux/dtbs -p
sudo cp output/images/fw_dynamic.bin output/images/Image /mnt/boot
sudo cp th1520-boot-firmware-20240127-sdk1.4.2/addons/boot/light_* /mnt/boot/
sudo cp output/images/light-lpi4a.dtb /mnt/boot/extlinux/dtbs
sudo rm /mnt/boot/lost+found -rf
```

Create `extlinux.conf`:

```bash
echo 'DEFAULT makeshiftos-default
MENU TITLE ------------------------------------------------------------
TIMEOUT 50

label makeshiftos-default
  MENU LABEL MakeShiftOS Default
  LINUX /Image
  FDT dtbs/light-lpi4a.dtb
  append root=/dev/mmcblk0p3 console=ttyS0,115200 rootwait rw earlycon clk_ignore_unused loglevel=7 eth= rootrwoptions=rw,noatime rootrwreset=yes' > extlinux.conf
sudo mv extlinux.conf /mnt/boot/extlinux/extlinux.conf
```

Unmount the filesystem and flash it to the LP4A board:

```
sync
sudo umount /mnt/boot
```

```
sudo ./fastboot flash ram output/images/u-boot-spl.bin
sudo ./fastboot reboot
sudo ./fastboot flash uboot output/images/u-boot-spl.bin
sudo ./fastboot flash boot output/images/bootfs.ext4
sudo ./fastboot flash root output/images/rootfs.ext4
```

(Optional) When connecting via UART you will need to set serial options in
the following way:

```
sudo stty -F /dev/ttyUSB0 ispeed 115200 ospeed 115200 cs8 raw
```

### References

- [Mark Corbin _ Buildroot for RISC-V](https://archive.fosdem.org/2019/schedule/event/riscvbuildroot/attachments/slides/3040/export/events/attachments/riscvbuildroot/slides/3040/FOSDEM_2019_Buildroot_RISCV.pdf)
- [Bootlin _ Embedded Linux from Scratch in 45 minutes, on RISC-V](https://www.youtube.com/watch?v=cIkTh3Xp3dA&t=1333s)
- [David Hand _ "Linux initramfs for fun, and, uh..."](https://www.youtube.com/watch?v=KQjRnuwb7is)
- [Device Tree for Dummies! - Thomas Petazzoni, Free Electrons](https://www.youtube.com/watch?v=m_NyYEBxfn8)
- [Kernel Recipes 2022 - Linux on RISC-V](https://www.youtube.com/watch?v=vcAVx8CV2fY)
- [RISC-V SBI and the full boot process](https://popovicu.com/posts/risc-v-sbi-and-full-boot-process/)
