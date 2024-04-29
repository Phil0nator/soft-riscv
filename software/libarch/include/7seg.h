#ifndef __SOFT_RISCV_7SEG
#define __SOFT_RISCV_7SEG

#include "arch.h"
#include "io.h"

/**
 * @brief set individual digits on the 7 segment dispaly
 * @warning This will override the current value present on the display
 * @param d0 The first digit (Must be 0-9)
 * @param d1 The first digit (Must be 0-9)
 * @param d2 The first digit (Must be 0-9)
 * @param d3 The first digit (Must be 0-9)
 * @returns On success, the 16-bit integer used to assign
 *  digits to the display is returned. On failure, an error code is returned.
*/
err_t seg7_set_digits(uint8_t d0, uint8_t d1, uint8_t d2, uint8_t d3);


#endif