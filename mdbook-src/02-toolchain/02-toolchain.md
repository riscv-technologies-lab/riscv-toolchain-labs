## Downloading toolchain and compiling your own

In this lab you will take a look at GNU and LLVM toolchains, where to find them and how to setup them
on your system.
You will also get acquainted with docker and its applications, we will use docker image with
prebuilt sc-dt package, which includes GNU ang LLVM toolchains.

### Docker usage

Navigate to [docker tutorials](https://github.com/riscv-technologies-lab/testgen-lectures/tree/main/tutorials)
in order to setup your docker.

Pull image and run container:
```bash
docker run \
    --interactive \
    --tty \
    --detach \
    --env "TERM=xterm-256color" \
    --mount type=bind,source="$(pwd)",target="$(pwd)" \
    --name cpp \
    --ulimit nofile=1024:1024 \
    ghcr.io/riscv-technologies-lab/rv_tools_image:1.0.1
```

Wait for the image to pull, then you will enter the container.

### Glancing at your first toolchain

The docker container has both GNU and LLVM toolchains in it. They are both installed in `/opt/sc-dt/` directory.

Here is the GNU toolchain: `/opt/sc-dt/riscv-gcc`
And here is the LLVM toolchain: `/opt/sc-dt/llvm/`

You will also see `env.sh` script in `/opt/sc-dt/` directory. This script exports environment variables to
your environment. Try running following:

```bash
source /opt/sc-dt/env.sh
```

*Task*: what changed after running the script? Take a look at your environmental variables before and after running the script. Compare and provide description. What does `source` command do?

Now you can access toolchains from `sc-dt` with either absolute typing: `/opt/sc-dt/riscv-gcc/` or
using environmental variable: `$SC_GCC_PATH/`

Navigate to `labs/02-toolchain/` directory.
Take a look at `hello.c`, this is the same program you tried at the previous lab, and the same `Makefile`.
We will use those with our new toolchain.

As you can see in the `Makefile`, there are a few variables at the top:

```makefile
CC ?= gcc
QEMU_USER ?= qemu-x86_64
CCFLAGS ?= 
```

It is a very common and a good practice to set such variables and use them throughout the Makefile.
The reason is, it is much more readable, and they can be redefined with some new value. For instance,
we can change the compiler, change the flags while using the same Makefile for our program.

Let's change the default compile in our `Makefile` to the one from sc-dt GNU toolchain:

*Note*: how do variables work in shell? Try accomplishing the same goal using `export` and explain the difference.

```bash
CC=/opt/sc-dt/riscv-gcc/bin/riscv64-unknown-linux-gnu-gcc QEMU_USER=/opt/sc-dt/tools/bin/qemu-riscv64 make build
```

Remember, if you encounter error like the following:

```
qemu-riscv64: Could not open '/lib/ld-linux-riscv64-lp64d.so.1': No such file or directory
```

Pass additionaly `CFLAGS=-static` along with `CC` and `QEMU_USER`

We redefined the `CC`, `CFLAGS` and  `QEMU_USER` variables to different value and ran build command. We see now that it ran successfully using specified compiler:

```bash
/opt/sc-dt/riscv-gcc/bin/riscv64-unknown-linux-gnu-gcc  hello.c -o build/hello.elf
```

Now run on QEMU:
```
CC=/opt/sc-dt/riscv-gcc/bin/riscv64-unknown-linux-gnu-gcc QEMU_USER=/opt/sc-dt/tools/bin/qemu-riscv64 CFLAGS=-static make run-qemu
```

### Connecting with debugger

It's time for us to use the debugger. We'll stick with GDB from sc-dt for now.

The debugger is located at `$SC_GCC_PATH/bin/riscv64-unknown-linux-gnu-gdb`

First, add `-g` to `CFLAGS` variable. This adds debug symbols to final binary.
They significantly affect binary size, but without them we cannot to proper debugging.
*Task*: compare binary size with and without debug symbols enabled. Use `objdump` tool from
toolchain to find those debug symbols added by compiler.

Now connect to qemu, make it wait for gdb connection:

`/opt/sc-dt/tools/bin/qemu-riscv64 -g 1234 build/hello.elf`

Open another terminal, and use gdb to connect to it:

`/opt/sc-dt/riscv-gcc/bin/riscv64-unknown-linux-gnu-gdb`

Inside gdb, connect to qemu by port 1234. Set breakpoint on main and run application:

```
target remote localhost:1234 # note: you can use "tar rem :1234"
b main
continue
```

Now you should see following:
```shell
(gdb) tar rem :1234
Remote debugging using :1234
Reading /home/stanislav/mipt/masters/riscv-toolchain-labs/labs/02-toolchain/fibb.elf from remote target...
warning: File transfers from remote targets can be slow. Use "set sysroot" to access files locally instead.
Reading /home/stanislav/mipt/masters/riscv-toolchain-labs/labs/02-toolchain/fibb.elf from remote target...
Reading symbols from target:/home/stanislav/mipt/masters/riscv-toolchain-labs/labs/02-toolchain/fibb.elf...
0x000000000001054c in _start ()
(gdb)
```


### Major tasks
#### Porting application to RISC-V

In this task, you must choose an application you will be porting (for instance, your application for quadratic equation solution) and port it to RISC-V:
* Create a Makefile for your application. Makefile should have build and run on qemu targets, you must be able to change compiler and simulator (and also compilation flags)
* For convenience, add Makefile target that runs on qemu / runs gdb / builds application using docker instead console:

```shell
make build-docker # This will enter docker container and build application inside it
```
* Build your app, verify that it runs on a simulator
* Build with both GNU and LLVM toolchain. Try different optimization levels, compare assemblers. Compare them and list some differences.