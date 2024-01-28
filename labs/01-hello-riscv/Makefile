CC ?= gcc
QEMU_USER ?= qemu-x86_64
CCFLAGS ?= 

BUILD_DIR := build
.DEFAULT_GOAL := hello

.PHONY: _build_dir hello clean

_build_dir:
	@mkdir -p ${BUILD_DIR}

hello: hello.c _build_dir
	${CC} ${CCFLAGS} hello.c -o ${BUILD_DIR}/hello.elf

build: hello

show: hello
	file ${BUILD_DIR}/hello.elf

run: hello
	${BUILD_DIR}/hello.elf

run-qemu: hello
	${QEMU_USER} ${BUILD_DIR}/hello.elf

clean:
	rm -r ${BUILD_DIR}
