`timescale 1ns/100ps


module __global_tb;

    initial begin
        $dumpfile("__global_tb.vcd");
        $dumpvars(0, __global_tb);
        #100000 $finish;
    end

endmodule