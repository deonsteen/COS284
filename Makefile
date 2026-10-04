ASM      := yasm
ASMFLAGS := -f elf64 -g dwarf2
CC       := gcc
CFLAGS   := -g -Wall -no-pie
TASKS    := $(wildcard task*.asm)

.PHONY: all run clean

all: library

library: main.c $(TASKS:.asm=.o)
	$(CC) $(CFLAGS) -o $@ $^ -lm -z noexecstack

%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

run: library
	./library

clean:
	rm -f library *.o
