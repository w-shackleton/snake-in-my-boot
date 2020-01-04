OUTPUT_FORMAT("elf32-i386");
/* We define an entry point to keep the linker quiet. This entry point
 * has no meaning with a bootloader in the binary image we will eventually
 * generate. Bootloader will start executing at whatever is at 0x07c00 */
ENTRY(start);
SECTIONS
{
    . = 0x7C00;
    .text : {
        /* Place the code in boot.o before all other code */
        boot.o(.text);
        *(.text);
    }

    /* Place the data after the code */
    .data : SUBALIGN(4) {
        *(.data);
        *(.rodata);
    }

    /* Place the boot signature at VMA 0x7DFE */
    .sig : AT(0x7DFE) {
        SHORT(0xaa55);
    }

    /* Place the uninitialised data in the area after our bootloader
     * The BIOS only reads the 512 bytes before this into memory */
    . = 0x7E00;
    .bss : SUBALIGN(4) {
        __bss_start = .;
        *(COMMON);
        *(.bss)
        . = ALIGN(4);
        __bss_end = .;
    }
    __bss_sizeb = SIZEOF(.bss);

    /* Remove sections that won't be relevant to us */
    /DISCARD/ : {
        *(.eh_frame);
        *(.comment);
        *(.note.gnu.build-id);
    }
}
