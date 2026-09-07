ASM      := yasm
ASMFLAGS := -f elf64 -g dwarf2
LD       := ld
TASKS    := task1 task2 task3 task4 task5

.PHONY: all clean test

all: $(TASKS)

task%: task%.o
	$(LD) -o $@ $<

task%.o: task%.asm
	$(ASM) $(ASMFLAGS) $< -o $@

test: all
	./tests/run.sh

clean:
	rm -f $(TASKS) *.o
