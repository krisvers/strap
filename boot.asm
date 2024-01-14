[bits 16]
org 0x7C00

boot:
	mov [DISKDL], dl

	xor ah, ah
	mov al, 0x03
	int 0x10

	xor ah, ah
	int 0x13

	mov ah, 0x02
	mov al, 0x02
	xor ch, ch
	mov cl, 0x02
	xor dh, dh
	mov bx, 0x07E0
	mov es, bx
	xor bx, bx
	int 0x13

	mov eax, [es:bx]
	cmp eax, DISKMAGIC

	mov ax, [es:bx + 4]
	test ax, ax
	mov al, 'm'
	jz error

	mov bx, 0x07C0
	mov es, bx
	xor bx, bx

	xor cx, cx

	.loop:
		call resetcursor
		mov dx, bx
		call printsector

		push bx
		mov bx, es
		mov ah, 0x0F
		call putword
		pop bx
		mov al, ':'
		call putc
		call putword

		xor ah, ah
		int 0x16

		cmp ah, 0x51
		jne .skip_pgup

		push bx
		mov bx, es
		add bx, 0x20
		mov es, bx
		pop bx

	.skip_pgup:
		cmp ah, 0x49
		jne .skip_pgdn

		push bx
		mov bx, es
		sub bx, 0x20
		mov es, bx
		pop bx

	.skip_pgdn:
		cmp ah, 0x52
		jne .skip_ins

		push bx
		mov bx, es
		sub bx, 0x100
		mov es, bx
		pop bx

	.skip_ins:
		cmp ah, 0x53
		jne .skip_del

		push bx
		mov bx, es
		add bx, 0x100
		mov es, bx
		pop bx

	.skip_del:
		cmp al, 'r'
		jne .skip_run

		jmp [es:bx]
	
	.skip_run:
		cmp al, 'w'
		jne .skip_write

		mov ah, 0x03
		mov al, 0x01
		xor ch, ch
		mov cl, 0x01
		xor dh, dh
		mov dl, [DISKDL]
		int 0x13

		jnc .loop

		mov al, 'w'
		jmp error
	
	.skip_write:
		cmp ah, 0x4B
		jne .skip_left

		dec bx

	.skip_left:
		cmp ah, 0x4D
		jne .skip_right

		inc bx

	.skip_right:
		cmp al, 0x30
		jl .skip_num

		cmp al, 0x39
		jg .skip_num

		mov ah, al
		sub ah, 0x30
		jmp .test_ch

	.skip_num:
		cmp al, 'a'
		jl .skip_char

		cmp al, 'f'
		jg .skip_char

		mov ah, al
		sub ah, 'a' - 10
		
	.test_ch:
		test ch, ch
		jnz .ch_zero

		shl ah, 0x04

	.ch_zero:
		or cl, ah
		inc ch

	.skip_char:
		cmp ch, 0x02
		jne .skip_set

		mov byte [es:bx], cl
		xor cx, cx
		xor ax, ax

	.skip_set:
		jmp .loop

	hlt

error:
	mov ah, 0xCF
	call putc

	hlt

; es = segment
; dx = byte to highlight
printsector:
	push ax
	push bx
	push cx

	xor bx, bx

	.loop:
		mov ah, [SECTCOL]
		cmp dx, bx
		jne .no_highlight

		sal ah, 0x04

	.no_highlight:
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
%include "disk.inc"

DISKDL: db 0xFF
SECTCOL: db 0x02

times 510-($-$$) db 0
dw 0xAA55