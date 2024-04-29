#ifndef __SOFT_RISCV_DELAY
#define __SOFT_RISCV_DELAY

#include "arch.h"

#define F_CPU       (100000000)

extern void __delay_cycles(uint64_t cycles);

#define CYCLES_FROM_us(us)      ((us)*(((F_CPU)/(1000000))))
#define _delay_us(us)           __delay_cycles(CYCLES_FROM_us(us))
#define _delay_ms(ms)           _delay_us(1000 * (ms))



#endif