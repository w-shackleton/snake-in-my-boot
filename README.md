# Snake in my Boot

An implementation of Snake written in bare-metal / BIOS x86 assembly and C that
fits into an MBR bootloader.

![A screenshot of the game running in QEMU](https://raw.githubusercontent.com/w-shackleton/snake-in-my-boot/master/demo.png)

## Design

*Check `References` for guides I used to write this*

Boot starts in `boot.asm` which sets up enough registers for C to be able to
run. This includes zeroing-out the BSS data segment created by GCC.

The "business logic" is all in C, with utility functions written in assembly.
The utility functions read the keyboard and draw the screen, both of which
require either interrupts or segments which GCC can't natively perform.

## Why not use inline asm?

I didn't want to.

## Why not write everything in asm?

I wanted to learn about how C interacts with assembly, how they are linked
together, and what bare-metal C looks like in x86.
