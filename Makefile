.PHONY: all bootloader disk run tools

all: bootloader disk

bootloader:
	nasm -f bin boot.asm -o boot.bin

disk:
	nasm -f bin disk.asm -o disk.bin
	cat boot.bin > disk.img
	cat disk.bin >> disk.img

run:
	qemu-system-i386 -blockdev driver=file,node-name=f0,filename=disk.img -device floppy,drive=f0

tools:
	gcc tools/disk.c -o tools/disk