

.align 4
.globl _start
.globl _start_end
.extern __soft_riscv_launchpad
.section .boot
_start:
    la sp, __stack_start # sp = __stack_start
    la gp, __global_pointer$ # gp = __global_pointer$
    call __soft_riscv_launchpad
    .final_hlt: j .final_hlt
_start_end: