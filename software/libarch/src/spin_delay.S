


.align 4
.globl __spin_delay_cycle
.section .text
__spin_delay_cycle:
    addi a0, a0, -1
    bne a0, zero, __spin_delay_cycle
    ret