all:
	nasm -f elf32 -g -F dwarf Lab03.asm -o Lab03.o
	ld -m elf_i386 Lab03.o -o Lab03

run: all
	./Lab03

