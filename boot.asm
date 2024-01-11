[bits 16]
org 0x7C00

boot:
	mov ah, 0x00
	mov al, 0x03
	int 0x10

	mov bx, 0x07C0
	mov es, bx
	call printsector

	jmp $

error:
	mov si, STR_ERR
	mov ah, 0x02
	call puts

	jmp $

; es = segment
printsector:
	push ax
	push bx
	push cx

	mov ah, 0x0F
	xor bx, bx

	.loop:
		mov al, [es:bx]
		call putbyte

		inc bx

		push ax

		mov ax, bx
		mov cl, 0x20
		div cl
		test ah, ah
		jz .skip2

		mov ax, bx
		mov cl, 0x02
		div cl
		test ah, ah
		jnz .skip1

		mov al, ' '
		call putc

	.skip1:
		mov ax, bx
		mov cl, 0x10
		div cl
		test ah, ah
		jnz .skip2

		mov al, ' '
		call putc

	.skip2:
		pop ax

		cmp bx, 0x0200
		jl .loop

	pop cx
	pop bx
	pop ax
	ret

%include "stdio.asm"

STR_ERR: db "Error", 0x00

times 510-($-$$) db 0
dw 0xAA55
