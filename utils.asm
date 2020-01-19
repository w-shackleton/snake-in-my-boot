global getkey
global sleep
global draw_cell
global cls
global shutdown
bits 16

CELL_SIZE equ 10
X_CELL_COUNT equ 32
X_RESOLUTION equ 320
VGA_SEGMENT equ 0xA000

section .text
getkey:
    ; Not using the stack so not pushing ebp etc
    ; int16/ah=11h: Keyboard: Check for enhanced stroke
    mov ah, 0x11
    int 0x16
    ; ZF clear if keystroke available: return it.
    jne return_popped_key
    ; else: return 0
    mov eax, 0
    retf
return_popped_key:
    ; int16/ah=10h: Keyboard: Get enhanced stroke
    mov ah, 0x10
    int 0x16
    ; Returns character in AL, scan code in AH. Clear top half of ax
    mov ah, 0
    retf


sleep:
    pushad
    ; int15/ah=86h: sleep in microseconds
    mov ah, 0x86
    ; cx - high word
    ; dx - low word
    ; 150,000 = 0x249F0. Approximate and zero-out dx
    mov cx, 0x2
    xor dx, dx
    int 15h
    popad
    retf


draw_cell:
    ; set up stack
    pushad
    mov ebp, esp

    ; normally xy = ebp+8, colour = ebp+12 since stack has ret ptr +
    ; ebp, but I'm using pushad to save bytes, so we have 8 dwords on stack +
    ; ret ptr. So xy = ebp+36, colour = ebp+40 etc

    ; set es segment to VGA segment and keep this for the duration of this func
    mov eax, VGA_SEGMENT
    mov es, ax

    ; store the remaining Y increments in bx
    mov ebx, CELL_SIZE
draw_line:
    ; decrement Y counter
    dec bx

    ; calculate initial VGA X offset into di
    mov eax, [ds:ebp+36]     ; load X coord into al, Y coord into ah
    mov dl, ah               ; load Y coord into dl
    mov ecx, CELL_SIZE
    mul cl                   ; mul X coord by 10, store in ax
    mov edi, eax             ; store result in edi
    mov al, dl               ; load Y coord into dl
    ; mov cx, CELL_SIZE -- Don't need to do this, CELL_SIZE already in ecx
    mul cl             ; mul by 10
    add ax, bx         ; add on current Y counter
    mov ecx, X_RESOLUTION
    mul cx             ; multiply by X resolution
    add di, ax

    ; write a row of pixels of the given colour
    mov ecx, CELL_SIZE
    mov al, [ds:ebp+40]
    rep stosb

    cmp bx, 0
    jne draw_line

    ; who knows what GCC expects; set es back to 0
    xor ax, ax
    mov es, ax

    ; tear down stack
    mov esp, ebp
    popad
    retf


cls:
    pushad
    mov ax, VGA_SEGMENT
    mov es, ax ; set es segment

    ; set game area to grey
    mov cx, 320 * 160
    xor di, di
    mov al, 0x14
    rep stosb

    ; We rely on the buffer starting black to keep the non-game area black.

    xor ax, ax
    mov es, ax ; reset es segment
    popad
    retf


shutdown:
    mov ax, 0x5301 ; connect to real-mode APM services
    xor bx, bx     ; device id 0 - APM BIOS
    int 0x15       ; call APM
    mov ax, 0x5307 ; set power state
    mov bx, 0x0001 ; on all devices
    mov cx, 0x0003 ; to Off
    int 0x15       ; call APM
