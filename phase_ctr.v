



module phase_ctr( input clk, input rstn, input en, output phase_fetch, output phase_execute, output phase_commit, output phase_step );


    reg [1:0] ctr = 0;
    reg [3:0] phase_decoded = 0;

    always @(posedge clk or negedge rstn) begin
        
        
        if (!rstn) begin
            ctr <= 0;
        end else if (en) begin
            
            case (ctr)
                0: phase_decoded = 1;
                1: phase_decoded = 2;
                2: phase_decoded = 4;
                3: phase_decoded = 8;
            endcase

            if (ctr >= 2) begin
                ctr <= 0;
            end else begin
                ctr <= ctr + 1;
            end

        end


    end
    

    assign phase_fetch = phase_decoded[0];
    assign phase_execute = phase_decoded[1];
    assign phase_commit = phase_decoded[2];
    assign phase_step = phase_decoded[3];
    



endmodule