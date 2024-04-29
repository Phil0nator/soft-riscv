#include "7seg.h"


err_t seg7_set_digits(uint8_t d0, uint8_t d1, uint8_t d2, uint8_t d3) {

    IO_7SEG = 0;
    if (d0 > 9) {
        return ERR_EARGS;
    }
    IO_7SEG += d0 * 1000;
    if (d1 > 9) {
        return ERR_EARGS;
    }
    IO_7SEG += d1 * 100;
    if (d2 > 9) {
        return ERR_EARGS;
    }
    IO_7SEG += d2 * 10;
    if (d3 > 9) {
        return ERR_EARGS;
    }
    IO_7SEG += d3;

    return ERR_SUCCESS;

}