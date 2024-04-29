
module phase_counter(
    input clk,
    input rstn,
    output phase_fetch,
    output phase_execute,
    output phase_commit
);
    reg [1:0] phase;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            phase <= 2;
        end else begin
            if (phase == 3) begin
                phase <= 0;
            end else begin
                phase <= phase + 1;
            end
        end
    end
    assign phase_fetch = (phase == 0);
    assign phase_execute = (phase == 1);
    assign phase_commit = (phase == 2);
endmodule


