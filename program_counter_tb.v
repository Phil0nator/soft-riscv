


module program_counter_tb;


    reg clk = 0;
    reg rstn = 1;
    reg phase_execute = 0, phase_commit = 0;
    reg [31:0] offset = 0;
    reg offset_en = 0;
    wire [31:0] pc;
    reg override;
    program_counter DUT(clk, rstn, offset, offset_en, override, phase_execute, phase_commit, pc );



    initial begin
        $dumpfile("program_counter_tb.vcd");
        $dumpvars(0, program_counter_tb);

        rstn = 0;
        #1
        rstn = 1;
        
        
        #2 phase_execute <= 1;
        #2 phase_execute <= 0; phase_commit <= 1;
        #2 phase_commit <= 0;
        #2 offset_en <= 1; offset <= 'h37;
        #2 phase_execute <= 1;
        #2 phase_execute <= 0; phase_commit <= 1;
        #2 phase_commit <= 0; offset_en <= 0;
        #2 offset <= 69; override <= 1;
        #2 phase_commit <= 1;
        #2 phase_commit <= 0; override <= 0;
        #10;
        

    end


    always #1 clk <= !clk;


endmodule