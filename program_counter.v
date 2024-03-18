




module program_counter(

    input clk,
    input rstn,
    input en,

    input [31:0] r_ra,
    input [31:0] r_rb,

    input [6:0] i_opcode,
    input [4:0] i_rd,
    input [2:0] i_func,
    input [4:0] i_rs1,
    input [4:0] i_rs2,
    input [6:0] i_funch,
    input [11:0] i_imm12,
    input [19:0] i_imm20,
    input [1:0] i_mode,


    input phase_step,
    input phase_execute,
    input phase_commit,


    output reg [31:0] pc,
    output reg [31:0] r_data,
    output reg r_wen,

);

    wire [31:0] sext_offset12;
    wire [31:0] sext_offset20;

    // left shift to immediates for 16-bit instruction width used
    // in instructions (even though the are 32-bits, offsets are specified
    // in 16-bit increments)
    sext u0 (.A(12), .Q(31)) ({i_imm12, 0}, sext_offset12);
    sext u1 (.A(20), .Q(31)) ({i_imm20, 0}, sext_offset20);

    


    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pc <= 0;
            r_data <= 0;
            r_wen <= 0;
        end else if (en) begin
            // branching instructions   (only operate during step phase)
            if (i_mode == 'b11000) begin
                if (phase_step) begin
                    case (i_func)
                        'b000: begin if ( r_ra == r_rb ) pc <= pc + sext_offset12; else pc <= pc + 4; end
                        'b001: begin if ( r_ra != r_rb ) pc <= pc + sext_offset12; else pc <= pc + 4; end 
                        'b100: begin if ( $signed(r_ra) < $signed(r_rb) ) pc <= pc + sext_offset12; else pc <= pc + 4; end
                        'b101: begin if ( $signed(r_ra) >= $signed(r_rb) ) pc <= pc + sext_offset12; else pc <= pc + 4; end
                        'b110: begin if ( r_ra < r_rb ) pc <= pc + sext_offset12; else pc <= pc + 4; end
                        'b111: begin if ( r_ra >= r_rb ) pc <= pc + sext_offset12; else pc <= pc + 4; end
                    endcase
                end
            // JALR instruction
            end else if (i_mode == 'b11001 && func == 0) begin
                // during execute phase, write to destination register
                if (phase_execute) begin
                    r_data <= pc + 4;
                    r_wen <= 1;
                // during step phase, update pc
                end else if (phase_step) begin
                    r_wen <= 0;
                    pc <= pc + (r_ra + sext_offset12) & (~1);
                end
            // JAL instruction
            end else if (i_mode == 'b11011) begin
                // during execute phase, write to destination register
                if (phase_execute) begin
                    r_data <= pc + 4;
                    r_wen <= 1;
                // during step phase, update pc
                end else if (phase_step) begin
                    r_wen <= 0;
                    pc <= pc + sext_offset20;
                end
            // Regular pc increment
            end else begin
                // normal step
                if (phase_step) begin
                    pc <= pc + 4;
                end
                r_wen <= 0;
            end


        end
    end




endmodule