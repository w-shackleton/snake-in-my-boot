extern main
extern __bss_sizeb
extern __bss_start

global start
bits 16

section .text
start:
    xor ax, ax            ; AX = 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x7C00 ; set stack pointer; stack grows down towards BOIS data area
    jmp 0x0000:setcs      ; Set CS to 0
setcs:
    cld                   ; GCC code requires direction flag to be cleared 

    ; Zero out BSS
    mov cx, __bss_sizeb
    mov di, __bss_start
    rep stosb ; stosb fills di -> cx bytes with the contents of ax

    ; Set video mode to 320x200
    ; mov ah, 0x00
    ; mov al, 0x13
    ; int 10h

    call dword main  ; enter C
    cli
    hlt
