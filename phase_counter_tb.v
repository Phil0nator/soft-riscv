`timescale 1ns/100ps


module phase_counter_tb();

    reg clk = 0;
    reg rstn = 1;
    wire phase_fetch, phase_execute, phase_commit;
    phase_counter DUT(clk, rstn, phase_fetch, phase_execute, phase_commit );









    initial begin
        $dumpfile("phase_counter_tb.vcd");
        $dumpvars(0, phase_counter_tb);

        rstn = 0;
        #1
        rstn = 1;
    end


    always #1 clk <= !clk;

endmodule