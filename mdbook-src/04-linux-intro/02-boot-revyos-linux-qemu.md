## Prerequisites

You will need to complete all of the steps described in the [preparations](04-linux-intro/01-preparations.md).
Do not forget to enter the container with `distrobox enter ubuntu-22.04-revyos-sdk`.

### Mounting the filesystem

```bash
mkdir revyos-with-qemu
cd revyos-with-qemu
cp <path to LPI4A_BASIC_20240111.zip> ./
unzip LPI4A_BASIC_20240111.zip
# Archive:  LPI4A_BASIC_20240111.zip
#    creating: LPI4A_BASIC_20240111/
#   inflating: LPI4A_BASIC_20240111/root.ext4
#   inflating: LPI4A_BASIC_20240111/boot.ext4
#   inflating: LPI4A_BASIC_20240111/flash_image.sh
#   inflating: LPI4A_BASIC_20240111/fastboot
#   inflating: LPI4A_BASIC_20240111/u-boot-with-spl-lpi4a.bin
#   inflating: LPI4A_BASIC_20240111/u-boot-with-spl-lpi4a-16g.bin 
```

The extracted image contains:

- `u-boot-with-spl-lpi4a.bin` - This is the secondary program loader (SPL) and primary uboot for 8Gb DDR board.
- `u-boot-with-spl-lpi4a-16g.bin` - Same as `u-boot-with-spl-lpi4a.bin`, but for the 16Gb variant.
- `root.ext4` - Root filesystem
- `boot.ext4` - Boot partition

```bash
fdisk -l LPI4A_BASIC_20240111/root.ext4
# Disk LPI4A_BASIC_20240111/root.ext4: 4 GiB, 4294967296 bytes, 8388608 sectors
# Units: sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 512 bytes
# I/O size (minimum/optimal): 512 bytes / 512 bytes
fdisk -l LPI4A_BASIC_20240111/boot.ext4
# Disk LPI4A_BASIC_20240111/boot.ext4: 500 MiB, 524288000 bytes, 1024000 sectors
# Units: sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 512 bytes
# I/O size (minimum/optimal): 512 bytes / 512 bytes
```

In order to view the contents of the filesystems you need to mount them.

```bash
sudo mkdir /mnt/boot /mnt/root -p
sudo mount LPI4A_BASIC_20240111/boot.ext4 /mnt/boot -v
# mount: /dev/loop0 mounted on /mnt/boot.
sudo mount LPI4A_BASIC_20240111/root.ext4 /mnt/root -v
# mount: /dev/loop1 mounted on /mnt/root.
cd /mnt/boot
# ⬢ [Docker] ❯ lla
# Permissions Size User Date Modified Name
# drwxr-xr-x     - root  9 Oct  2023   dtbs
# drwxr-xr-x     - root 14 Dec  2023   extlinux
# drwx------     - root  9 Oct  2023   lost+found
# .rw-r--r--  167k root  6 Sep  2023   config-5.10.113-lpi4a
# .rwxr-xr-x   86k root  8 Oct  2023   fw_dynamic.bin
# .rwxr-xr-x   23M root 20 Dec  2023   Image
# .rw-r--r--  5.2M root  9 Oct  2023   initrd.img-5.10.113-lpi4a
# .rwxr-xr-x   50k root  6 Sep  2023   light_aon_fpga.bin
# .rwxr-xr-x  6.1M root  8 Oct  2023   light_c906_audio.bin
# .rw-r--r--  6.2M root  6 Sep  2023   System.map-5.10.113-lpi4a
# .rwxr-xr-x   23M root  6 Sep  2023   vmlinux-5.10.113-lpi4a
```

Files of the primary interest are:

- `fw_dynamic.bin` - OpenSBI with dynamic information. More info at [fw_dynamic.md](https://github.com/riscv-software-src/opensbi/blob/master/docs/firmware/fw_dynamic.md)
- `dtbs` - Compiled device tree binaries.
- `Image` - Kernel, which is run by the bootloader (uboot). This is a statically linked binary.
- `vmlinux-5.10.113-lpi4a` - Kernel binary produced during the compilation process. Is not bootable.
- `initrd.img-5.10.113-lpi4a` - Initial ram disk for *Phase 1* init before rootfs can be mounted.

To view the contents of `initrd` it first needs to be uncompressed.

```bash
cd <path to revyos-with-qemu>
cp /mnt/boot/initrd.img-5.10.113-lpi4a .
file initrd.img-5.10.113-lpi4a
# initrd.img-5.10.113-lpi4a: gzip compressed data, was "mkinitramfs-MAIN_oNzF9f", last modified: Mon Oct  9 14:10:38 2023, from Unix, original size modulo 2^32 12879360
gunzip initrd.img-5.10.113-lpi4a -d -c > initrd.img-5.10.113-lpi4a.cpio
file initrd.img-5.10.113-lpi4a.cpio
# initrd.img-5.10.113-lpi4a.cpio: ASCII cpio archive (SVR4 with no CRC)
cpio --list -i < ./initrd.img-5.10.113-lpi4a.cpio | head -n 15
# .
# bin
# conf
# conf/arch.conf
# conf/conf.d
# conf/initramfs.conf
# etc
# etc/fstab
# etc/ld.so.cache
# etc/ld.so.conf
# etc/ld.so.conf.d
# etc/ld.so.conf.d/libc.conf
# etc/ld.so.conf.d/riscv64-linux-gnu.conf
# etc/modprobe.d
# etc/mtab
# 25155 blocks
mkdir initrd-contents
cpio -idmv < ../initrd.img-5.10.113-lpi4a.cpio
# ⬢ [Docker] ❯ lla
# Permissions Size Date Modified Name
# lrwxrwxrwx     - 26 Mar 12:02   bin -> usr/bin
# drwxr-xr-x     - 26 Mar 12:02   conf
# drwxr-xr-x     - 26 Mar 12:02   etc
# lrwxrwxrwx     - 26 Mar 12:02   lib -> usr/lib
# drwxr-xr-x     -  9 Oct  2023   run
# lrwxrwxrwx     - 26 Mar 12:02   sbin -> usr/sbin
# drwxr-xr-x     - 26 Mar 12:02   scripts
# drwxr-xr-x     - 26 Mar 12:02   usr
# .rwxr-xr-x  6.6k 10 Apr  2022   init
```

### Running the extracted image with QEMU

Now that we have everything extracted it's easy to run the image
with the custom vendor fork of qemu, which you've previously compiled from source.

First you will need to modify the `/mnt/root/etc/fstab` file a bit.
Replace the contents of the file with the following:

```
# UNCONFIGURED FSTAB FOR BASE SYSTEM
/dev/vda /   auto    defaults    1 1
/dev/vdb /boot   auto    defaults    0 0
```

To do this you can use your faviourite editor.

```bash
echo "# UNCONFIGURED FSTAB FOR BASE SYSTEM
/dev/vda /   auto    defaults    1 1
/dev/vdb /boot   auto    defaults    0 0
" > fstab
sudo cp fstab /mnt/root/etc/fstab
cat /mnt/root/etc/fstab
# # UNCONFIGURED FSTAB FOR BASE SYSTEM
# /dev/vda /   auto    defaults    1 1
# /dev/vdb /boot   auto    defaults    0 0
```

Now you can launch qemu with the following command:

```bash
sudo umount /mnt/root
e2fsck -y LPI4A_BASIC_20240111/root.ext4
e2fsck -y LPI4A_BASIC_20240111/boot.ext4
sync
revyos-qemu/build/qemu-system-riscv64 -M virt -cpu c910v -smp 1 -m 3G -kernel /mnt/boot/Image -append "root=/dev/vda rw console=ttyS0" -drive file=LPI4A_BASIC_20240111/root.ext4,format=raw,id=hd0 -device virtio-blk-device,drive=hd0 -drive file=LPI4A_BASIC_20240111/boot.ext4,format=raw,id=hd1 -device virtio-blk-device,drive=hd1 -initrd /mnt/boot/initrd.img-5.10.113-lpi4a -nographic
```

You will see the boot log that looks something like this:

```
OpenSBI v0.9
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|____/_____|
        | |
        |_|

Platform Name             : riscv-virtio,qemu
Platform Features         : timer,mfdeleg
Platform HART Count       : 1
Firmware Base             : 0x80000000
Firmware Size             : 100 KB
Runtime SBI Version       : 0.2

....

[    0.000000] Linux version 5.10.113+ (ubuntu@ubuntu-2204-buildserver) (riscv64-unknown-linux-gnu-gcc (Xuantie-900 linux-5.10.4 glibc gcc Toolchain V2.6.1 B-20220906) 10.2.0, GNU ld (GNU Binutils) 2.35) #1 SMP PREEMPT Wed Dec 20 08:25:29 UTC 2023
[    0.000000] OF: fdt: Ignoring memory range 0x80000000 - 0x80200000
[    0.000000] efi: UEFI not found.
[    0.000000] Initial ramdisk at: 0x(____ptrval____) (5160960 bytes)
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000080200000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000080200000-0x000000013fffffff]
```

After a while you should see the login prompt:

```bash
[  OK  ] Started serial-getty@ttyS0…rvice - Serial Getty on ttyS0.
[  OK  ] Reached target getty.target - Login Prompts.
[  OK  ] Reached target multi-user.target - Multi-User System.
[  OK  ] Reached target graphical.target - Graphical Interface.
         Starting systemd-update-ut… Record Runlevel Change in UTMP...
[  OK  ] Finished systemd-update-ut… - Record Runlevel Change in UTMP.

Debian GNU/Linux 12 lpi4a ttyS0

lpi4a login:
```

Enter the default login `debian` and password `debian` as documented in the [docs](https://wiki.sipeed.com/hardware/en/lichee/th1520/lpi4a/3_images.html).

You should now be in the shell:

```

   ____              _ ____  ____  _  __  ____  _                     _
  |  _ \ _   _ _   _(_) ___||  _ \| |/ / / ___|(_)_ __   ___  ___  __| |
  | |_) | | | | | | | \___ \| | | | ' /  \___ \| | '_ \ / _ \/ _ \/ _` |
  |  _ <| |_| | |_| | |___) | |_| | . \   ___) | | |_) |  __/  __/ (_| |
  |_| \_\\__,_|\__, |_|____/|____/|_|\_\ |____/|_| .__/ \___|\___|\__,_|
               |___/                             |_|
                                        -- Presented by ISCAS and Sipeed

  Debian GNU/Linux 12 (bookworm) (kernel 5.10.113+)

Linux lpi4a 5.10.113+ #1 SMP PREEMPT Wed Dec 20 08:25:29 UTC 2023 riscv64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
debian@lpi4a:~$
```

The image contains python3 so you can run a basic hello-world in the python repl:

```bash
python3
# Python 3.11.4 (main, Jun  7 2023, 10:13:09) [GCC 12.2.0] on linux
# Type "help", "copyright", "credits" or "license" for more information.
# >>> print("Hello, World")
# Hello, World
<Ctrl + D>
```

Run `uname` utility to print the information about current machine:

```bash
uname -a
# Linux lpi4a 5.10.113+ #1 SMP PREEMPT Wed Dec 20 08:25:29 UTC 2023 riscv64 GNU/Linux
```
