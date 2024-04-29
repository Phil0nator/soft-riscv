

module alu_tb;

    reg clk = 0;
    reg [2:0] fun3;
    // bits 31-25
    reg [6:0] func7;
    // bits 6-2
    reg [31:0] ALUin1;
    reg [31:0] ALUin2;
    wire [31:0] ALUout;   

    alu DUT(
        clk, fun3, func7, ALUin1, ALUin2, ALUout
    );

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        #10     // ADD
        ALUin1 <= 5;
        ALUin2 <= 7;
        fun3 <= 3'b000;
        func7 <= 7'b0000000;
        #10     // SUB
        fun3 <= 3'b000;
        func7 <= 7'b0100000;
        #10     // lsl
        fun3 <= 3'b001;
        func7 <= 7'b0000000;
        #10     // AND
        fun3 <= 3'b111;
        func7 <= 7'b0000000;
        #10000;
        
    end


endmodule