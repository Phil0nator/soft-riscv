`timescale 1ns/100ps

module top_tb;


    reg rst = 0, clk = 0;
    reg [15:0] sw;
    wire [15:0] leds;
    wire [3:0] red;
    wire [3:0] blue;
    wire [3:0] green;
    top DUT(rst, clk, sw, bt, Hsync, Vsync, red, green, blue, leds, anodes, cathodes);


    initial begin
        forever begin
            #1 clk <= ~clk; sw <= $random;
        end
    end


    initial begin
        #1 rst <= 1;
        #1 rst <= 0;

        #100000 $finish;
    end

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
    end


endmodule