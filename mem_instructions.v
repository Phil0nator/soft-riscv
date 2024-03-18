


module mem_instructions(

    input clk,
    input rstn,
    input en,

    input [4:0] rd,
    input [2:0] func,
    input [4:0] rs1,
    input [4:0] rs2,
    input [6:0] funch,
    input [31:0] sext_imm12,
    input [31:0] sext_imm20,
    input [4:0] mode,

    input phase_execute,
    input phase_commit,

    input [31:0] rs1,
    input [31:0] rs2,
    input [31:0] m_din,

    output reg [31:0] r_data,
    output reg r_wen,
    output reg [31:0] m_addr,
    output reg [31:0] m_dout,
    output reg m_wen,


);


    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            
        end else if (en) begin
            // load
            if (mode == 0) begin
                // setup address to read
                if (phase_execute) begin
                    m_addr <= rs1 + sext_imm12;
                    m_wen <= 0;
                // setup 
                end else if (phase_commit) begin
                    r_wen <= 1; // write to register
                    case (func)
                        'b000: r_data <= {{(24){m_din[7]}}, m_din[7:0] };  // lb
                        'b001: r_data <= {{(16){m_din[15]}}, m_din[15:0] };  // lh
                        'b010: r_data <= m_din;  // lw
                        'b100: r_data <= {(24){0}, m_din[7:0]};   // lbu
                        'b101: r_data <= {(16){0}, m_din[15:0]};   // lhu
                    endcase
                end
            // store
            end else if (mode == 'b01000) begin
                if (phase_execute) begin
                    
                end else if (phase_commit) begin
                    m_addr <= rs1 + sext_imm12;
                    m_wen <= 1;
                    
                    // TODO different sized writes???

                end
            end else begin
                m_wen <= 0;
                r_wen <= 0;
            end
        end
    end



endmodule