all: clean compile link

clean:
	rm -f *.o task2

compile:
	nasm -f elf32 start.s -o start.o
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector util.c -o util.o
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector main.c -o main.o
	

link:
	ld -m elf_i386 start.o main.o util.o -o task2

gcc: clean
	gcc -m32 -Wall -ansi -c main.c -o main.o
	gcc -m32 -Wall -ansi -c main.o -o main