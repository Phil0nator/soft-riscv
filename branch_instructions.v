

module branch_instructions(
    input en,
    input [2:0] funct3,
    input jal,
    input jalr,
    input branch,
    
    input [31:0] rs1,
    input [31:0] rs2,
    
    input [31:0] Boffset,
    input [31:0] JALoffset,
    input [31:0] JALRoffset,

    output reg pc_offset_en,
    output reg [31:0] pc_offset,
    output reg pc_override
);

    always @(*) begin
        if (en) begin
            if (branch) begin
                
                pc_offset <= Boffset;
                case (funct3)
                    'b000: pc_offset_en <= (rs1 == rs2);
                    'b001: pc_offset_en <= (rs1 != rs2);
                    'b100: pc_offset_en <= ($signed(rs1) < $signed(rs2));
                    'b101: pc_offset_en <= ($signed(rs1) >= $signed(rs2));
                    'b110: pc_offset_en <= ($unsigned(rs1) < $unsigned(rs2));
                    'b111: pc_offset_en <= ($unsigned(rs1) >= $unsigned(rs2));
                    default: begin
                        // BIG ERROR :(
                    end
                endcase

            end else if (jal) begin
                pc_offset <= JALoffset;
                pc_offset_en <= 1;
            end else if (jalr) begin
                pc_offset <= JALRoffset;
                pc_override <= 1;
            end else begin
                // BIG ERROR :(
            end

        end else begin
            pc_offset_en <= 0;
            pc_override <= 0;
            pc_offset <= 0;
        end
    end


endmodule