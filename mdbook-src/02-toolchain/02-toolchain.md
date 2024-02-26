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

``
