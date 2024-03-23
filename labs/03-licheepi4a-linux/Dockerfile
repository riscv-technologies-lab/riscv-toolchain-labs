ARG BASE_IMAGE="ubuntu:22.04"

FROM $BASE_IMAGE AS qemu-build

ARG QEMU_REPO=https://github.com/revyos/qemu
ARG QEMU_REVISION=ab8f84892a89feea60f1bb24432ff58ce6d2885c

RUN apt-get update -qy && \
    apt-get install -qy ninja-build python3-venv build-essential \
      libglib2.0-dev flex bison libpixman-1-dev git

WORKDIR /tmp/

RUN git clone --recurse-submodules $QEMU_REPO qemu-src

WORKDIR qemu-src

RUN git reset --hard $QEMU_REVISION
RUN ./configure --target-list=riscv64-softmmu,riscv64-linux-user --prefix=$(pwd)/build/install && make -j install

FROM $BASE_IMAGE

COPY --from=qemu-build /tmp/qemu-src/build/install/ /usr/local/

RUN apt-get update -qy && \
    apt-get install -qy git fdisk gdisk file

