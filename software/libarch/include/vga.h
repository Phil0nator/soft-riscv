
#ifndef __SOFT_RISCV_VGA
#define __SOFT_RISCV_VGA

#include "arch.h"

/* 8-bit color type used for VGA */
typedef uint8_t vga_color_t;

/// VGA Color constants

/* Create a VGA color using 8-bit RGB of (3, 3, 2) bits */
#define VGA_RGB(r,g,b)  ((g & 0x7) | ((r & 0x7) << 3) | ((b & 0x3) << 6))
#define VGA_BLACK       VGA_RGB(0,0,0)
#define VGA_WHITE       VGA_RGB(7,7,3)
#define VGA_RED         VGA_RGB(7,0,0)
#define VGA_BLUE        VGA_RGB(0,0,3)
#define VGA_GREEN       VGA_RGB(0,7,0)
#define VGA_MAGENTA     VGA_RGB(7,0,3)

/* VGA Display Width */
#define VGA_WIDTH       (120)
/* VGA Display Height */
#define VGA_HEIGHT      (160)
/* VGA Display Buffer Size */
#define VGA_SIZE        (VGA_WIDTH * VGA_HEIGHT)

/* Used internally -- a pointer to the current VGA buffer */
extern volatile vga_color_t* __cur_vga_buf;

/* Get a pointer to a coordinate in the current VGA buffer */
#define VGA_COORD( x, y ) (__cur_vga_buf + (VGA_WIDTH * (y)) + (x))
/* Draw a color to a pixel in the current buffer */
#define VGA_DRAW_PX(x, y, color)    (*(VGA_COORD(x,y)) = (color))


typedef struct vgabuf {

    vga_color_t *buffer;
    uint16_t width, height;

} vgabuf_t;


void vgabuf_create( vgabuf_t* buf, vga_color_t* memory, uint16_t width, uint16_t height );

void vga_draw_rect( int x, int y, int w, int h, vga_color_t color );
void vga_blit( int x, int y, vgabuf_t* buf );

void vga_flip();
void vga_clear(vga_color_t color);

err_t vga_putchar(int x, int y, int scale, char c, vga_color_t col);
err_t vga_puts(int x, int y, int scale, const char* s, vga_color_t col);

#endif