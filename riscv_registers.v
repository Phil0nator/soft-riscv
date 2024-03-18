



module riscv_registers(

    input clk,
    input rstn,

    input cs,
    input [4:0] ra,
    input [4:0] rb,
    input [4:0] rd,
    input wen,
    input [31:0] data,
    output [31:0] a,
    output [31:0] b,
    output [31:0] d
);


    reg [31:0] registers [31:0];

    always @(posedge clk or negedge rstn) {

        if (!rstn) begin
            
            integer ri;
            for (ri = 0; ri < 32; ri = ri + 1) begin
                registers[ri] = 0;
            end

        end else if (cs) begin

            a <= registers[ra];
            b <= registers[rb];
            d <= registers[rd];
            if (wen) begin
                registers[rd] <= data;
            end

        end


    }





endmodule