magic: dd DISKMAGIC
disklen: dw 0x0001

%include "disk.inc"

times 1024-($-$$) db 0