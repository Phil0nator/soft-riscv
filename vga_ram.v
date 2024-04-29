/*
    This is a true dual port RAM module targeting a Xilinx Series 7 Chip
    It follows the template laid out in Xilinx UG901 and is meant to be used
    for a DMA VGA controller
*/
module vga_ram(
                input clka,
                input clkb,
                
                input ena,
                input enb,
                
                input [3:0] wea,
                input [3:0] web,
                
                input [31:0] addra,
                input [31:0] addrb,
                
                input [31:0] dina,
                input [31:0] dinb,
                
                output reg [31:0] douta,
                output reg [31:0] doutb
                );
localparam WEN_SIZE = 8; //set write enable to select by bytes
localparam RAM_DEPTH = 4800; //set memory depth to (RAM_DEPTH * 4)KB
                
reg [31:0] ram [RAM_DEPTH-1:0];
integer i;


//this follows the recommended coding practices provided in Xilinx UG901

always @(posedge clka) begin
    if(ena) begin
        for(i=0;i<4;i=i+1) begin
            if(wea[i]) begin
              ram[addra][i*WEN_SIZE +: WEN_SIZE] <= dina[i*WEN_SIZE +: WEN_SIZE];  
            end
        end
        douta <= ram[addra];
    end
end

always @(posedge clkb) begin
    if(enb) begin
        for(i=0;i<4;i=i+1) begin
            if(web[i]) begin
              ram[addrb][i*WEN_SIZE +: WEN_SIZE] <= dinb[i*WEN_SIZE +: WEN_SIZE];  
            end
        end
        doutb <= ram[addrb];
    end
end
                 
                
endmodule