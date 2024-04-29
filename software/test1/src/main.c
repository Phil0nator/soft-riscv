

#include "arch.h"
#include "io.h"
#include "delay.h"
#include "vga.h"


int main() {

    // vga_puts(5,5,1, "Hello World!", VGA_WHITE);

    // vga_clear(VGA_RED);
    // vga_flip();
    // vga_clear(VGA_RED);

    VGA_DRAW_PX( 10, 10, VGA_RED );
    VGA_DRAW_PX( 11, 11, VGA_RED );
    VGA_DRAW_PX( 12, 12, VGA_RED );
    VGA_DRAW_PX( 13, 13, VGA_RED );
    

    // __cur_vga_buf[0] = VGA_BLUE;
    // __cur_vga_buf[1] = VGA_GREEN;
    // __cur_vga_buf[2] = VGA_WHITE;
    // __cur_vga_buf[3] = VGA_MAGENTA;

    (*(uint32_t*)(__cur_vga_buf)) = (
        VGA_BLUE + (VGA_GREEN << 8) + (VGA_WHITE << 16) + (VGA_MAGENTA << 24)
    );

    ((uint32_t*)(__cur_vga_buf))[2] = (
        VGA_BLUE + (VGA_GREEN << 8) + (VGA_WHITE << 16) + (VGA_MAGENTA << 24)
    );
    
    IO_7SEG = 6973;
    int px = 20;
    int py = 20;
    while (1) {
        // for (int i = 0; i < 16; i++) {
        //     IO_LED_TOGGLE(i);
        //     _delay_ms(100);
        // }
        
        

        VGA_DRAW_PX(px,py, VGA_RED);

        if (IO_BUTTON_GET(3)) {
            px ++;
            _delay_ms(100);
        }

        if (IO_BUTTON_GET(1)) {
            py ++;
            _delay_ms(100);
        }

        if (IO_BUTTON_GET(0)) {
            py --;
            _delay_ms(100);
        }

        if (IO_BUTTON_GET(2)) {
            px --;
            _delay_ms(100);
        }


    }


    // IO_7SEG = 5;




    return EXIT_SUCCESS;
}