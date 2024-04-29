



module riscv_registers(

    input clk,
    input rstn,

    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    input [4:0] rd,
    input wen,
    input [31:0] data,
    output reg [31:0] rs1,
    output reg [31:0] rs2
);


    reg [31:0] registers [31:0];

    integer rdumper;
    initial begin
        for (rdumper = 0; rdumper < 32; rdumper = rdumper + 1) $dumpvars(0, registers[rdumper]);
    end

    always @(*) begin

        if (!rstn) begin
            
        end else begin

            rs1 <= registers[rs1_addr];
            rs2 <= registers[rs2_addr];
            if (wen && rd != 0) begin
                registers[rd] <= data;
            end

        end


    end





endmodule