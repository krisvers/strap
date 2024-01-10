[bits 16]
org 0x7C00

boot:
	mov ah, 0x00
	mov al, 0x03
	int 0x10

	mov al, 'B'
	mov ah, 0x0F
	call putc

	mov si, STR_ERR
	mov ah, 0x02
	call puts

	jmp $

puts:
	.loop:
		lodsb

		test al, al
		jz .done

		call putc
		jmp .loop

.done:
	ret

putc:
	push es
	push ax
	push bx
	push cx
	push dx

	mov bx, [VIDEO_SEG]
	mov es, bx
	mov bx, [VIDEO_OFF]

	cmp al, 0x0A
	jne .skip

	mov ax, bx
	mov cx, 0xA0
	div cx
	add bx, 0xA0
	sub bx, dx

	cmp bx, 0x50 * 0x14 * 0x02
	jne .done

	xor bx, bx 
	jmp .done

.skip:
	mov [es:bx], al
	inc bx
	mov [es:bx], ah
	inc bx

.done:
	mov [VIDEO_OFF], bx

	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	ret

VIDEO_SEG: dw 0xB800
VIDEO_OFF: dw 0x0000
STR_ERR: db "Error", 0x0A, "Test", 0x00

times 510-($-$$) db 0
dw 0xAA55
