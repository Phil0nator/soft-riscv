

`include "constants.v"


module program_counter(
    input clk,
    input rstn,
    input [31:0] offset,

    // offset_en will cause offset to be added to pc
    input offset_en,
    // override will cause offset to be assigned to pc
    input override,
    input phase_execute,
    input phase_commit,
    output reg [31:0] pc
);
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pc <= `PROGRAM_BASE_ADDR;
        end else begin
            if (phase_execute && offset_en) begin
                pc <= pc + offset;
            end else if (phase_execute && override) begin
                pc <= offset;
            end else if (phase_execute) begin
                pc <= pc + 4;
            end
        end
    end
endmodule