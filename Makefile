all: bootloader disk

bootloader:
	nasm -f bin boot.asm -o boot.bin

disk:
	cat boot.bin > disk.img

run:
	qemu-system-i386 -fda disk.img
