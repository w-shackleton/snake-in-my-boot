global getkey
global sleep
global draw_cell
global cls
global brk
bits 16

CELL_SIZE equ 10
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
    xchg bx, bx
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
    ; 300,000 = 0x493E0
    mov cx, 0x4
    mov dx, 0x93E0
    int 15h
    popad
    retf


draw_cell:
    ; set up stack
    xchg bx, bx
    pushad
    mov ebp, esp

    ; normally x = ebp+8, y = ebp+12, colour = ebp+16 since stack has ret ptr +
    ; ebp, but I'm using pushad to save bytes, so we have 8 dwords on stack +
    ; ret ptr. So x = ebp+36, y = ebp+40 etc

    ; set es segment to VGA segment and keep this for the duration of this func
    mov eax, VGA_SEGMENT
    mov es, ax

    ; store the remaining Y increments in bx
    mov ebx, CELL_SIZE
draw_line:
    ; decrement Y counter
    dec bx

    ; calculate initial VGA X offset into di
    mov eax, [ds:ebp+36]     ; load X coord
    mov ecx, CELL_SIZE
    mul cx             ; mul by 10
    mov edi, eax         ; store in di
    mov ax, [ds:ebp+40]    ; load Y coord
    mov cx, CELL_SIZE
    mul cx             ; mul by 10
    add ax, bx         ; add on current Y counter
    mov ecx, X_RESOLUTION
    mul cx             ; multiply by X resolution
    add di, ax

    ; write a row of pixels of the given colour
    mov ecx, CELL_SIZE
    mov al, [ds:ebp+44]
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
    mov cx, 320 * 200
    mov di, 0
    mov al, 0
    rep stosb
    xor ax, ax
    mov es, ax ; reset es segment
    popad
    retf


brk:
    xchg bx, bx
    retf
