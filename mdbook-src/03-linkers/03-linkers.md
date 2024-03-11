## Learning linkers

In this lab, you will gain hands-on experience with relocations, how linkers resolve them,
as well as get some knowledge about static / dynamic linking. Navigate to `labs/03-linkers` to see the examples we've prepared for you.

### Definitions and declarations

\<\<\<\<\<\<\< HEAD

*Declaration* in C introduces identifier and describes its type, whether it is a type, object or a function.

*Definition* in C instantiates / implement the identifier. It is what linker needs in order to make references to those entities.

Take a look at following declarations:

```c
extern int bar;
extern int mul(int a, int b);
double sum(int a, double b);
struct foo;
```

# and declarations:

Take a look at `main.c` and `fact.c` provided.

> > > > > > > 402b1ca (Modify examples for RISC-V)

```c
int main() {
  unsigned f = fact(5);
  printf("%u\n", f);
  return 0;
}
```

```c

unsigned fact(unsigned x) {
  if (x < 2)
    return 1;

  return x * fact(x - 1);
}

```

First, let's from here use only `RISC-V toolchain`:

```shell
source /opt/sc-dt/env.sh # NOTE: if you are using something other than bash, this might not work. If so, try the old fashioned path export
export CC=/opt/sc-dt/riscv-gcc/bin/
export PATH=${PATH}:/opt/sc-dt/riscv-gcc/bin
export PATH=${PATH}:/opt/sc-dt/tools/bin # For QEMU
```

`main` here does not know that `fact` function exists. If we try to compile main to the executable `make exec`, we will get following error:

```shell
/opt/sc-dt/riscv-gcc/bin/../lib/gcc/riscv64-unknown-linux-gnu/12.2.1/../../../../riscv64-unknown-linux-gnu/bin/ld: /tmp/ccqIh9oC.o: in function `main':
main.c:(.text+0xa): undefined reference to `fact'
collect2: error: ld returned 1 exit status
```

Linker failed to find definition for *the definition* for `fact` function.

#### Task 3.1

Use `readelf` and `file` utilities to investigate  `main.o` file and its contents and answer following questions:

Format for the following assignment: answer the questions in markdown file.

- What is the type of the file?
- How many sections are there?
- List all entries in the same format `readelf`
  prints it
- Why does entries for `print` and `fact` functions have `NOTYPE` type?
- Modify the following example so executable is produced correctly.

### Relocations

Let's take a look at `objdump` output:

```
riscv64-unknown-linux-gnu-objdump -d main.o
```

We will notice that we have address of factorial function is all zeroes:

```shell
    e:	000080e7          	jalr	ra # a <main+0xa>
```

Now compile both files and link into a single executable and look at the call address:

```shell
make bin
```

```shell
riscv64-unknown-linux-gnu-objdump -d fact | grep fact
```

You will see that fact now has been assigned an address and `main` nows how to call it:

```shell
fact:     file format elf64-littleriscv
   105fc:	028000ef          	jal	ra,10624 <fact>
0000000000010624 <fact>:
   1063c:	00e7e463          	bltu	a5,a4,10644 <fact+0x20>
   10642:	a839                	j	10660 <fact+0x3c>
   1064e:	fd7ff0ef          	jal	ra,10624 <fact>

```

The linker managed to find `fact` function and insert the correct address for it. It used *relocations* to do it.

```shell
riscv64-unknown-linux-gnu-readelf -r main.o
```

Possible output:

```shell
Relocation section '.rela.text' at offset 0x268 contains 8 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
00000000000a  000c00000012 R_RISCV_CALL      0000000000000000 fact + 0
00000000000a  000000000033 R_RISCV_RELAX                        0
00000000001e  00080000001a R_RISCV_HI20      0000000000000000 .LC0 + 0
00000000001e  000000000033 R_RISCV_RELAX                        0
000000000022  00080000001b R_RISCV_LO12_I    0000000000000000 .LC0 + 0
000000000022  000000000033 R_RISCV_RELAX                        0
000000000026  000d00000012 R_RISCV_CALL      0000000000000000 printf + 0
000000000026  000000000033 R_RISCV_RELAX                        0
```

From the output we see that both `fact` and `printf` names calls have their relocations. These relocations are provided by compiler to asssist linker in resolving symbols.

### Static libraries

The following command:

```
riscv64-unknown-linux-gnu-gcc main.c fact.c  -o fact
```

compiles program to executable. But no linker here is invoked? Or is it?

Pass `--verbose` flag to dive deeper into what gcc actually calls under the hood.

Find `collect2` call line:

```
/opt/sc-dt/riscv-gcc/bin/../libexec/gcc/riscv64-unknown-linux-gnu/12.2.1/collect2 -plugin /opt/sc-dt/riscv-gcc/bin/../libexec/gcc/riscv64-unknown-linux-gnu/12.2.1/liblto_plugin.so -plugin-opt=/opt/sc-dt/riscv-gcc/bin/../libexec/gcc/riscv64-unknown-linux-gnu/12.2.1/lto-wrapper -plugin-opt=-fresolution=/tmp/cc1yCRZY.res -plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_s -plugin-opt=-pass-through=-lc -plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_s --sysroot=/opt/sc-dt/riscv-gcc/bin/../sysroot --eh-frame-hdr -melf64lriscv -dynamic-linker /lib/ld-linux-riscv64-lp64d.so.1 -o fact /opt/sc-dt/riscv-gcc/bin/../sysroot/usr/lib64/lp64d/crt1.o /opt/sc-dt/riscv-gcc/bin/../lib/gcc/riscv64-unknown-linux-gnu/12.2.1/crti.o /opt/sc-dt/riscv-gcc/bin/../lib/gcc/riscv64-unknown-linux-gnu/12.2.1/crtbegin.o -L/opt/sc-dt/riscv-gcc/bin/../lib/gcc/riscv64-unknown-linux-gnu/12.2.1 -L/opt/sc-dt/riscv-gcc/bin/../lib/gcc -L/opt/sc-dt/riscv-gcc/bin/../lib/gcc/riscv64-unknown-linux-gnu/12.2.1/../../../../riscv64-unknown-linux-gnu/lib/../lib64/lp64d -L/opt/sc-dt/riscv-gcc/bin/../sysroot/lib/../lib64/lp64d -L/opt/sc-dt/riscv-gcc/bin/../lib/gcc/riscv64-unknown-linux-gnu/12.2.1/../../../../riscv64-unknown-linux-gnu/lib -L/opt/sc-dt/riscv-gcc/bin/../sysroot/lib64/lp64d -L/opt/sc-dt/riscv-gcc/bin/../sysroot/usr/lib64/lp64d -L/opt/sc-dt/riscv-gcc/bin/../sysroot/lib /tmp/ccOEmH9J.o /tmp/cc6v5KHP.o -lgcc --push-state --as-needed -lgcc_s --pop-state -lc -lgcc --push-state --as-needed -lgcc_s --pop-state /opt/sc-dt/riscv-gcc/bin/../lib/gcc/riscv64-unknown-linux-gnu/12.2.1/crtend.o /opt/sc-dt/riscv-gcc/bin/../lib/gcc/riscv64-unknown-linux-gnu/12.2.1/crtn.o

```

`collect2` is the actual command called in the process of linking.

Try examining every argument and describe what it is responsible for.

Mostly all of the arguments are paths to libraries.

Static libraries are embedded to applications code directly.

Let's create or own little static library:

```
riscv64-unknown-linux-gnu-ar cr libfact.o fact.o
```

Use `nm` utility to get the list of symbols available in the archive:

```
riscv64-unknown-linux-gnu-nm libfact.o
```

```
fact.o:
0000000000010294 r __abi_tag
0000000000012040 B __BSS_END__
0000000000012038 B __bss_start
0000000000012038 b completed.0
0000000000012000 D __DATA_BEGIN__
0000000000012000 D __data_start
0000000000012000 W data_start
000000000001048a t deregister_tm_clones
00000000000104d0 t __do_global_dtors_aux
0000000000011e18 d __do_global_dtors_aux_fini_array_entry
0000000000012030 D __dso_handle
0000000000011e20 d _DYNAMIC
0000000000012038 D _edata
0000000000012040 B _end
0000000000010524 T fact
00000000000104f2 t frame_dummy
0000000000011e10 d __frame_dummy_init_array_entry
0000000000010608 r __FRAME_END__
0000000000012020 d _GLOBAL_OFFSET_TABLE_
0000000000012800 A __global_pointer$
00000000000105cc r __GNU_EH_FRAME_HDR
0000000000011e18 d __init_array_end
0000000000011e10 d __init_array_start
0000000000012028 D _IO_stdin_used
00000000000105c2 T __libc_csu_fini
000000000001056a T __libc_csu_init
                 U __libc_start_main@GLIBC_2.27
000000000001047e t load_gp
00000000000104f4 T main
                 U printf@GLIBC_2.27
0000000000010410 t _PROCEDURE_LINKAGE_TABLE_
00000000000104a8 t register_tm_clones
0000000000012028 D __SDATA_BEGIN__
0000000000010450 T _start
0000000000012000 D __TMC_END__

```

To link with your static or dynamic library, pass `-llib`  argument to compilation flags. `lib` is the name of library.

Note that linking directly with `ld` is strongly discouraged, instead, use `gcc` or `clang` driver and pass additional options to linker if needed.

#### Task 3.2

- Create a separare directory with files for your static library
- Write Makefile target which creates static library
- Use `nm` to find out what
- Write Makefile target which links
- Create your own static library for RISC-V. It would be even better if application was useful, for instance, a custom C logging library.

### Dynamic linking

Static linking is portable, because all library code is embedded in the application and no platform support required. But this makes application's code size increase dramatically.

The solution to this problem is **dynamic libraries**

Let's create our little dynamic library and link our application against it:

```shell
CFLAGS=-fPIC make fact
riscv64-unknown-linux-gnu-gcc -shared fact.o -o libfact.so
```

```shell
$ file libfact.so
libfact.so: ELF 64-bit LSB shared object, UCB RISC-V, RVC, double-float ABI, version 1 (SYSV), dynamically linked, not stripped

```

Now link your library against `libfact.so`:

```
riscv64-unknown-linux-gnu-gcc main.o -o fact -lfact
/opt/sc-dt/riscv-gcc/bin/../lib/gcc/riscv64-unknown-linux-gnu/12.2.1/../../../../riscv64-unknown-linux-gnu/bin/ld: cannot find -lfact: No such file or directory
collect2: error: ld returned 1 exit status
```

This happened because our `libfact.so` is in the current working directory, and linker does not now it should look here.

You can pass paths where linker should search for the libraries with `-L` option:

```
riscv64-unknown-linux-gnu-gcc main.o -o fact -L. -lfact
```

We told the linker to search for `libfact` inside our current working directory.

```
file fact
fact: ELF 64-bit LSB executable, UCB RISC-V, RVC, double-float ABI, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-riscv64-lp64d.so.1, for GNU/Linux 4.15.0, not stripped
```

Now let's run it with qemu:

```
❯ qemu-riscv64 ./fact
./fact: error while loading2 shared libraries: libfact.so: cannot open shared object file: No such file or directory

```

What is wrong? We linker the library, didn't we?

The reason is that though we specified where to look for dynamic library, we didn't put that information in the binary.

Let's do it using `rpath`:

```
riscv64-unknown-linux-gnu-gcc main.o -o fact -L. -lfact -Wl,-rpath,.
```

Now let's try again:

```
qemu-riscv64  ./fact
./fact: error while loading shared libraries: libc.so.6: cannot open shared object file: No such file or directory
```

Now `qemu` failed to find the C standard library.
We already know how to fix it, let's pass path to `glibc`:

```
❯ qemu-riscv64 -L . -L /opt/sc-dt/riscv-gcc/sysroot/ ./fact
120
```

Our factorial finally works, and we learned to create dynamic libraries.

#### Task 3.3

- Create your own little dynamic library. First do it with x86 toolchain, then for RISCV.
- Link application with the library and make it run on QEMU and on LicheePi (when available).
