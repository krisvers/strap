; ah = color
; bx = word number
putword:
    push ax

    mov al, bh
    call putbyte
    mov al, bl
    call putbyte

    pop ax
    ret

; al = byte number
; ah = color
putbyte:
    push ax
    push bx
    push cx

    mov cl, al
    mov ch, cl
    shr ch, 0x04
    and cl, 0x0F

    mov bx, HEX_CHARS
    add bl, ch
    mov al, [bx]
    call putc

    mov bx, HEX_CHARS
    add bl, cl
    mov al, [bx]
    call putc
    
    pop cx
    pop bx
    pop ax
    ret

; al = character
; ah = color
putc:
	push es
	push bx
	push cx

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

	jmp .done

.skip:
	mov [es:bx], al
	inc bx
	mov [es:bx], ah
	inc bx

.done:
	cmp bx, 0x0FA0
	jl .done2

	xor bx, bx

.done2:
	mov [VIDEO_OFF], bx

	pop cx
	pop bx
	pop es
	ret

resetcursor:
	mov word [VIDEO_OFF], 0

	ret

VIDEO_SEG: dw 0xB800
VIDEO_OFF: dw 0x0000
HEX_CHARS: db "0123456789ABCDEF"