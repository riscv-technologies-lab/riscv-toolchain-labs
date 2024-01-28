# Introduction to cross-compilation

This lesson shall serve as an introduction to cross-compilation and user mode
emulation. We assume the reader has some previous knowledge of C/C++ languages
and is familiar with linux and command line. It's recommended to review the following
resources before diving into practical aspects:

- [Introduction to cross-compiling for Linux](http://landley.net/writing/docs/cross-compiling.html)
- [Toolchain & Pony 🦄](https://youtu.be/335ylTUlyng?si=VbfusqEvtgz4_iNL)

In this lesson you will learn how to build a simple C program targeting with cross-gcc toolchain targeting riscv64 arch
and run it on your computer via [qemu-user](https://www.qemu.org/docs/master/user/main.html).
