
#include "delay.h"
#include "io.h"


extern void __delay_cycles(uint64_t cycles) {
    IO_TIMER0 = 0;
    while (IO_TIMER0 < cycles) {
        // nop
    }
}


