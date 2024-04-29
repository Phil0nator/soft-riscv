
#ifndef __SOFT_RISCV_IO
#define __SOFT_RISCV_IO

#include "arch.h"

/* Set bit `b` of `x` */
#define BIT_SET(x, b)   ((x) |= (1 << (b)))
/* Clear bit `b` of `x` */
#define BIT_CLR(x, b)   ((x) &= ~(1 << (b)))
/* Toggle bit `b` of `x` */
#define BIT_TOG(x, b)   ((x) ^= (1 << (b)))
/* Get bit `b` of `x` */
#define BIT_GET(x, b)   (((x) & (1 << (b))) ? 1 : 0)
/* Assign value 'v' to bit 'b' of 'x' */
#define BIT_ASSIGN(x, b, v)    ((v) ? (BIT_SET(x,b)) : (BIT_CLR(x,b)))

#define abs(x)      (((x) < 0) ? (-(x)) : (x))

#define __IO_REG(addr) (*(volatile uint32_t*)(addr))
#define __IO_REG64(addr) (*(volatile uint64_t*)(addr))

/* 7 Segment Display Register */
#define IO_7SEG     __IO_REG(0x04)
/* LED Register */
#define IO_LEDS     __IO_REG(0x08)
/* Button inputs register */
#define IO_BUTTONS  __IO_REG(0x0C)
/* Switch input register */
#define IO_SWITCHES __IO_REG(0x10)
/* VGA Control Register */
#define IO_VGA_CTRL __IO_REG(0x14)

#define IO_FLAGS    __IO_REG(0x18)

#define IO_TIMER0_L __IO_REG(0x1C)

#define IO_TIMER0_H __IO_REG(0x20)

#define IO_TIMER0   __IO_REG64(0x1C)

typedef void (*__fault_handler_t);

#define IO_FAULT_ADDR   (*(__fault_handler_t)(0x24))

/* VGA Buffer Number Control Bit */
#define IO_VGA_CTRL_BUFNO_BIT   (0)

/* Turn on led `n` */
#define IO_LED_ON(n)        BIT_SET(IO_LEDS, n)
/* Turn off led `n` */
#define IO_LED_OFF(n)       BIT_CLR(IO_LEDS, n)
/* Toggle led `n` */
#define IO_LED_TOGGLE(n)    BIT_TOG(IO_LEDS, n)
/* Get the state of led `n` */
#define IO_LED_GET(n)       BIT_GET(IO_LEDS, n)

/* Get the state of button `n` */
#define IO_BUTTON_GET(n)    BIT_GET(IO_BUTTONS, n)
/* Get the state of switch `n` */
#define IO_SWITCH_GET(n)    BIT_GET(IO_SWITCHES, n)


#endif