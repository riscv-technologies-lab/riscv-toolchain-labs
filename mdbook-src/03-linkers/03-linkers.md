## Learning linkers

In this lab, you will learn about relocations, how linkers resolve them,
as well as get some knowledge about static / dynamic linking. Navigate to `labs/03-linkers` to see the examples we've prepared for you.

### Definitions and declarations

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

```c
int bar;
int mul(int a, int b) { return a * b; }
double sum(int a, double b) { return a + b; }
struct foo {};
```

There can be always multiple *definitions*, but only one *declaration*. Otherwise, linker would not be able to tell which of the definitions it should use. It must use only on of them, but it can't tell exactly which one.

### Relocations
