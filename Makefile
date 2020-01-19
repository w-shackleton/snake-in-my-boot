all: game.bin

boot.o: boot.asm
	nasm -f elf32 boot.asm -o boot.o

utils.o: utils.asm
	nasm -f elf32 utils.asm -o utils.o

game.o: game.c utils.h
	gcc -fno-PIC -ffreestanding -fomit-frame-pointer -m16 -Os -c game.c -o game.o

game.elf: game.o link.ld boot.o utils.o
	ld -melf_i386 -T link.ld game.o boot.o utils.o -o game.elf

game.bin: game.elf
	objcopy -O binary game.elf game.bin

run: game.bin
	qemu-system-i386 -fda game.bin

bochs: game.bin
	bochs -f bochsrc

objdump: game.elf
	objdump -D -mi386 -Maddr16,data16 game.elf
