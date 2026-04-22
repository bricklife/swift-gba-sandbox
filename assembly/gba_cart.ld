ENTRY(_start)

MEMORY
{
    rom (rx)    : ORIGIN = 0x08000000, LENGTH = 32M
    iwram (rwx) : ORIGIN = 0x03000000, LENGTH = 32K
    ewram (rwx) : ORIGIN = 0x02000000, LENGTH = 256K
}

SECTIONS
{
    .crt0 :
    {
        KEEP(*(.crt0))
    } > rom = 0xff

    .text :
    {
        *(.text)
        . = ALIGN(4);
    } > rom = 0xff

    /* Stabs debugging sections. */
    .debug 0 : { *(.debug_*) }
    .comment 0 : { *(.comment) }
    .ARM.attributes 0 : { *(.ARM.attributes) }
    .symtab 0 : { *(.symtab) }
    .shstrtab 0 : { *(.shstrtab) }
    .strtab 0 : { *(.strtab) }
}
