global getkey
global sleep
bits 16

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
    ret
return_popped_key:
    ; int16/ah=10h: Keyboard: Get enhanced stroke
    mov ah, 0x10
    int 0x16
    ; Returns character in AL, scan code in AH. Clear top half of ax
    mov ah, 0
    ret


sleep:
    ; int15/ah=86h: sleep in microseconds
    mov ah, 0x86
    ; cx - high word
    ; dx - low word
    ; 1,000,000 = 0xF4240
    mov cx, 0xF
    mov dx, 0x4240
    int 15h
    ret
