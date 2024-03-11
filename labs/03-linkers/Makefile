
CC ?= gcc
CFLAGS ?= -O0
QEMU_USER ?= qemu-x86_64
BIN := example

.PHONY: clean

clean:
	rm *.o ${BIN} fact

bin: main.c fact.c
	${CC} ${CFLAGS} $^ -o fact

main: main.c
	${CC} ${CFLAGS} $^ -c -o $@.o

fact: fact.c
	${CC} ${CFLAGS} $^ -c -o $@.o

example: main.c
	${CC} ${CFLAGS} $^ -o ${BIN}
