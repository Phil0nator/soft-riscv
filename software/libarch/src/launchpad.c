

#include "arch.h"
#include "io.h"
#include "delay.h"


extern err_t main();

void __soft_riscv_launchpad() {
    
    err_t status = main();
    if (status == EXIT_SUCCESS) {
        for(;;);
    } else {
        /*
            Errors returned from main are now displayed on the 7 Seg,
            and the LEDs are flashed to indicate an error.
        */

       IO_7SEG = abs(status);

        for(;;) {
            IO_LEDS = ~IO_LEDS;
            _delay_ms(500);   
        }

    }
}