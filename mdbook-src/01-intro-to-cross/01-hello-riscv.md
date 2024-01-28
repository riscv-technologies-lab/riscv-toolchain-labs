## Compiling our first hello world program

First clone this [repo](https://github.com/riscv-technologies-lab/riscv-toolchain-labs) and install the cross toolchain for riscv64.
This depends on your distribution. We assume a debian based operating system, but feel free to use any distro you want.

```bash
sudo apt install build-essential gcc-riscv64-linux-gnu qemu-user
```

Clone and navigate to the `labs/01-hello-riscv` directory:

```bash
git clone https://github.com/riscv-technologies-lab/riscv-toolchain-labs.git cross-labs
cd cross-labs/labs/01-hello-riscv
```

Let's compile a simple hello world program natively. Take a look at
the `Makefile` that we've prepared.

```c
{{#include ../../labs/01-hello-riscv/hello.c}}
```

```bash
make run # compile the program natively
# gcc hello.c -o build/hello.elf
# build/hello.elf
# Hello, RISC-V!
```

Let's take a look at the generated executable with `file` command:

```bash
make show # run: file build/hello.elf
# gcc hello.c -o build/hello.elf
# file build/hello.elf
# build/hello.elf: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=52deb0fc601275b33ab8a638447f4bf2dcc1bb4a, for GNU/Linux 3.2.0, not stripped
```

We can dig deeper with `ldd` [command](https://man7.org/linux/man-pages/man1/ldd.1.html).

```bash
ldd build/hello.elf
# linux-vdso.so.1 (0x00007fff042e9000)
# libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f058ff59000)
# /lib64/ld-linux-x86-64.so.2 (0x00007f0590169000)
```

What is [vDSO](https://man7.org/linux/man-pages/man7/vdso.7.html)?
Now run `readelf` utility on the compiled binary and take explore the output by yourself.
What happens if you compile with `CCFLAGS=-static` and run `readelf` again? Why is the output bigger?

## Running under qemu usermode emulation

Run `hello.elf` with native [usermode qemu](https://www.qemu.org/docs/master/user/main.html).
There's a make target to do that:

```
make run-qemu
```

## Compile and run for riscv64 arch

Repeat the previous steps but with `riscv64` toolchain. You can set make variables
from command line, if they are defined with `?=`. Take a look [here](https://ftp.gnu.org/old-gnu/Manuals/make-3.79.1/html_chapter/make_6.html#SEC58).
Set the compiler to `riscv64-linux-gnu-gcc` and qemu executable to `qemu-riscv64`.
On ubuntu-23.04 `make run-qemu` fails with `Could not open '/lib/ld-linux-riscv64-lp64d.so.1'`.
In case you encounter such an error run you can either compile with `-static` flag or create
symlink `riscv64-linux-gnu-ld` with `ln -s` to the correct location. See the [issue](https://github.com/riscv-non-isa/riscv-elf-psabi-doc/issues/114).
