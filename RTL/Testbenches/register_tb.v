


module register_tb;


    reg clk = 0;
    reg rstn = 1;

    reg [4:0] rs1_addr = 0;
    reg [4:0] rs2_addr = 0;
    reg rd = 0;
    reg wen = 0;
    reg [31:0] data = 0;
    wire [31:0] rs1;
    wire [31:0] rs2;

    riscv_registers DUT(
        clk,
        rstn,
    
        rs1_addr,
        rs2_addr,
        rd,
        wen,
        data,
        rs1,
        rs2
    );


    initial begin
        $dumpfile("register_tb.vcd");
        $dumpvars(0, register_tb);

        rstn = 0;
        #1
        rstn = 1;
        
        #2 rd <= 1; data <= 69; wen <= 1;
        #2 wen <= 0; rs1_addr <= 1;
        #2 data <= 23;
        #2 rs2_addr <= 1;

        #2 rstn <= 0;
        #2 rstn <= 1;
        

    end


    always #1 clk <= !clk;


endmodule