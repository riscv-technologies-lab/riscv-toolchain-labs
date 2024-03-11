
CC := gcc
CFLAGS := -O0
QEMU_USER := qemu-x86_64

.PHONY: clean

clean:
	rm *.o

main: main.c
	${CC} ${CFLAGS} $^ -c -o $@.o

fact: fact.c
	${CC} ${CFLAGS} $^ -c -o $@.o
