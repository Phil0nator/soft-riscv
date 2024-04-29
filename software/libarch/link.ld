OUTPUT_ARCH("riscv")
ENTRY(_start)



SECTIONS {
    . = 0x40;
    __program_start = .;
    .text : ALIGN(4)
    {
        *(.boot)
        *(.text)
    }
    .data : 
    {
        . = ALIGN(4);
        *(.data)
    }
    PROVIDE(__global_pointer$ = .);
    .bss :
    {
        . = ALIGN(4);
        *(.bss)
    }
    _end = .;
    __heap_start = .;
    __stack_start = 0x7FFF;
    __vga_1 = 0x100000;
    __vga_2 = 0x200000;
}