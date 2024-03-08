

// per cheat sheet PDF
module riscv_decode(

    input [31:0] ins,

    output [6:0] opcode,
    output [4:0] rd,
    output [2:0] func,
    output [4:0] rs1,
    output [4:0] rs2,
    output [6:0] funch,
    
    output [11:0] imm12,
    output [19:0] imm20,

    output [1:0] mode,

);




    assign opcode = ins[6:0];

    assign rd = ins[11:7];
    assign func = ins[14:12];
    assign rs1 = ins[19:15];
    assign rs2 = ins [24:20];
    assign funch = ins[31:25];

    assign mode = ins[6:2];

    assign imm20 = ins[31:12];

    assign imm12 = (mode == 5'b11000) ? 
        {ins[11:7], ins[31:25]} : ins[31:20];
    


endmodule