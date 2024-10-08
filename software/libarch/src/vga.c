#include "arch.h"
#include "vga.h"
#include "io.h"

volatile vga_color_t* __cur_vga_buf = (volatile vga_color_t*) MEM_VGA_1_START;
static uint8_t vga_active_bufno = 0;


void vga_flip() {
    vga_active_bufno = !vga_active_bufno;
    if (vga_active_bufno) {
        __cur_vga_buf = (vga_color_t*) MEM_VGA_2_START;
    } else {
        __cur_vga_buf = (vga_color_t*) MEM_VGA_1_START;
    }

    BIT_TOG(IO_VGA_CTRL, IO_VGA_CTRL_BUFNO_BIT);
}
void vga_clear(vga_color_t color) {
    vga_color_t color_buf[] = {color,color,color,color};
    uint32_t color_filler = *(uint32_t*)(&color_buf[0]);
    for(int i = 0; i < (VGA_SIZE / 4); i++)
        ((uint32_t*)(__cur_vga_buf))[i] = (color_filler);
}

void vga_draw_rect( int x, int y, int w, int h, vga_color_t color ) {
    for(int dx = 0; dx < w; dx ++)
        for (int dy = 0; dy < h; dy ++)
            VGA_DRAW_PX(x+dx, y+dy, color);
}

void vga_blit( int x, int y, vgabuf_t* buf ) {
    for (int dx = 0; dx < buf->width; dx ++)
        for (int dy = 0; dy < buf->height; dy++)
            VGA_DRAW_PX(x + dx, y + dy, buf->buffer[ dx + (dy * buf->width) ]);
}

void vgabuf_create( vgabuf_t* buf, vga_color_t* memory, uint16_t width, uint16_t height ) {
    buf->buffer = memory;
    buf->width = width;
    buf->height = height;
}


/// TEXT

#define GLYPH_WIDTH 5
#define GLYPH_HEIGHT 6
// https://github.com/azmr/blit-fonts/blob/master/blit32.h
static const uint32_t font1_glyph[] = {
    /* all chars up to 32 are non-printable */
		0x00000000,0x08021084,0x0000294a,0x15f52bea,0x08fa38be,0x33a22e60,0x2e94d8a6,0x00001084,
        0x10421088,0x04421082,0x00a23880,0x00471000,0x04420000,0x00070000,0x0c600000,0x02222200,
        0x1d3ad72e,0x3e4214c4,0x3e22222e,0x1d18320f,0x210fc888,0x1d183c3f,0x1d17844c,0x0222221f,
        0x1d18ba2e,0x210f463e,0x0c6018c0,0x04401000,0x10411100,0x00e03800,0x04441040,0x0802322e,
        0x3c1ef62e,0x231fc544,0x1f18be2f,0x3c10862e,0x1f18c62f,0x3e10bc3f,0x0210bc3f,0x1d1c843e,
        0x2318fe31,0x3e42109f,0x0c94211f,0x23149d31,0x3e108421,0x231ad6bb,0x239cd671,0x1d18c62e,
        0x0217c62f,0x30eac62e,0x2297c62f,0x1d141a2e,0x0842109f,0x1d18c631,0x08454631,0x375ad631,
        0x22a21151,0x08421151,0x3e22221f,0x1842108c,0x20820820,0x0c421086,0x00004544,0xbe000000,
        0x00000082,0x1c97b000,0x0e949c21,0x1c10b800,0x1c94b908,0x3c1fc5c0,0x42211c4c,0x4e87252e,
        0x12949c21,0x0c210040,0x8c421004,0x12519521,0x0c210842,0x235aac00,0x12949c00,0x0c949800,
        0x4213a526,0x7087252e,0x02149800,0x0e837000,0x0c213c42,0x0e94a400,0x0464a400,0x155ac400,
        0x36426c00,0x4e872529,0x1e223c00,0x1843188c,0x08421084,0x0c463086,0x0006d800,
};

#define GLYPH_BIT(gx, gy, g)    BIT_GET(g, ( gx + (gy * GLYPH_WIDTH) ))   

err_t vga_putchar(int x, int y, int scale, char c, vga_color_t col) {
    
    if (c < ' ' || c > 126) {
        return ERR_EARGS;
    }
    
    uint32_t glyph = font1_glyph[c - ' '];
    for (int dx = 0; dx < GLYPH_WIDTH; dx ++) {
        for (int dy = 0; dy < GLYPH_HEIGHT; dy ++) {
            if (GLYPH_BIT(dx, dy, glyph)) {
                VGA_DRAW_PX(x + dx, y + dy, col);
            }
        }
    }

    return ERR_SUCCESS;
}

err_t vga_puts(int x, int y, int scale, const char* s, vga_color_t col) {

    int char_width = scale * GLYPH_WIDTH;
    err_t err;
    while (*s) {
        if ((err = vga_putchar(x, y, scale, *s, col)) != ERR_SUCCESS) {
            return err;
        }
        s++;
        x += char_width;
    }

    return x;

}