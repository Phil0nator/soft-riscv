


module core(

    input clk,
    input rstn,
    input en,

    input [31:0] instruction,
    input [31:0] data,

    output [31:0] pc,       // program counter
    output reg [31:0] mar,      // data memory address register
    output reg [31:0] mdr,      // data memory data out register
    output reg dwen,            // data memory write enable 
    output reg ins_read,        // pulse to update instruction from memory blocks
    output reg mem_read,        // pulse to update data from memory blocks




);

    ///// 
    // continuous instruction components:
    /////
    wire [6:0] i_opcode;
    wire [4:0] i_rd;
    wire [2:0] i_func;
    wire [4:0] i_rs1;
    wire [4:0] i_rs2;
    wire [6:0] i_funch;
    wire [11:0] i_imm12;
    wire [19:0] i_imm20;
    wire [1:0] i_mode;

    decoder_base decoder(instruction, i_opcode, i_rd, i_func, i_rs1, i_rs2, i_funch, i_imm12, i_imm20, i_mode);

    wire [31:0] sext_imm12;
    sext sext0 (.A(11), .Q(31)) (i_imm12, sext_imm12);

    wire [31:0] sext_imm20;
    sext sext1 (.A(19), .Q(31)) (i_imm20, sext_imm20);

    //////
    // Register file components
    //////
    wire [4:0] r_ra;
    assign r_ra = i_rs1;
    wire [4:0] r_rb;
    assign r_rb = i_rs2;
    wire [4:0] r_rd;
    assign r_rd = i_rd;
    reg r_wen;
    reg [31:0] r_data;
    wire [31:0] r_a;
    wire [31:0] r_b;
    wire [31:0] r_d;
    reg [31:0] lock_ra;
    reg [31:0] lock_rb;
    riscv_registers registers( clk, rstn, en, r_ra, r_rb, r_rd, r_wen, r_data, r_a, r_b, r_d);


    //////
    // ALU components
    //////
    wire [31:0] alu_out;
    wire alu_zf;
    reg [31:0] alu_a;
    reg [31:0] alu_b;
    ALU alu(i_func, i_funch, i_mode, alu_a, alu_b, alu_out, alu_zf);



    //////
    // Phase counter components
    //////
    wire phase_fetch, phase_execute, phase_commit, phase_step;
    phase_ctr phase(clk, rstn, en, phase_fetch, phase_execute, phase_commit, phase_step);



    ///////
    // Program counter components
    ///////
    wire [31:0] pctr_dout;
    wire pctr_rwen;

    program_counter pctr(
        clk,
        rstn,
        en,

        lock_ra,
        lock_rb,

        i_opcode,
        i_rd,
        i_func,
        i_rs1,
        i_rs2,
        i_funch,
        i_imm12,
        i_imm20,
        i_mode,


        phase_step,
        phase_execute,
        phase_commit,


        pc,
        pctr_dout,
        pctr_rwen,
    );





    always @(posedge clk or negedge rstn) begin
        
        if (!rstn) begin
            // TODO
        end else if(en) begin

            if (phase_fetch) begin
                ins_read <= 1;




            end else if (phase_execute) begin
                // correct instruction is loaded into the instruction register
                ins_read <= 0;
                mem_read <= 1;

                // load register values
                lock_ra <= r_a;
                lock_rb <= r_b;

                // ALU instructions with both registers:
                if (i_mode == 'b01100) begin
                    alu_a <= r_a;
                    alu_b <= r_b;
                // ALU instructions with immedate
                end else if (i_mode == 'b00100 ) begin
                    alu_a <= r_a;
                    alu_b <= sext_imm12;
                end


            end else if (phase_commit) begin
                mem_read <= 0;

                // ALU instructions
                if (i_mode == 'b01100) begin
                    r_wen <= 1;
                    r_data <= alu_out;
                // Program counter register writes
                end else if (pctr_rwen) begin
                    r_wen <= 1;
                    r_data <= pctr_dout;
                // LUI instruction
                end else if (i_mode == 'b01101) begin
                    r_wen <= 1;
                    r_data <= sext_imm20 << 12;
                // AUIPC instruction
                end else if (i_mode == 'b00101) begin
                    r_wen <= 1;
                    r_data <= pc + sext_imm20 << 12;
                // TODO: memory loads
                end else if (0) begin
                    
                end else begin
                    r_wen <= 0; // register non-modifying
                end


            end else if (phase_step) begin
                
            end else begin
                // This should NEVER occur
            end


        end
    end






endmodule




