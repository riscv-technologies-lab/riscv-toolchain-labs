## Learning linkers

In this lab, you will gain hands-on experience with relocations, how linkers resolve them,
as well as get some knowledge about static / dynamic linking. Navigate to `labs/03-linkers` to see the examples we've prepared for you.

### Definitions and declarations
<<<<<<< HEAD

*Declaration* in C introduces identifier and describes its type, whether it is a type, object or a function.

*Definition* in C instantiates / implement the identifier. It is what linker needs in order to make references to those entities.

Take a look at following declarations:

```c
extern int bar;
extern int mul(int a, int b);
double sum(int a, double b);
struct foo;
```

and declarations:
=======

Take a look at `main.c` and `fact.c` provided.
>>>>>>> 402b1ca (Modify examples for RISC-V)

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


#### Question
Use `readelf` and `file` utilities to investigate  `main.o` files and its contents and answer following questions:
* What is the type of the file?
* How many sections are there?
* List all entries in the same format `readelf`
  prints it
* Why does entries for `print` and `fact` functions have `NOTYPE` type?
* Modify the following example so executable is produced correctly.

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

From the output we see that both `fact` and `printf` names calls have their relocations. These relocations are used
