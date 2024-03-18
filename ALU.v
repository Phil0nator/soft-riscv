


module ALU( 

// bits 14-12
input [2:0] func,
// bits 31-25
input [6:0] funch,
// bits 6-2
input [4:0] mode,
input [31:0] ALUin1,
input [31:0] ALUin2,

output reg [31:0] ALUout,   
output zeroflag             //active high zero flag

);

assign zeroflag = (ALUout == 0) ? 1 : 0;

always @(*) begin
    case({funch,func})
        'b0000000000: ALUout = (ALUin1 + ALUin2);                                //0, addition
        'b0100000000: ALUout = (ALUin1 - ALUin2);                                //1, subtraction
        'b0000000001: ALUout = (ALUin1 << ALUin2);                               //2, Logical left shift
        'b0000000010: ALUout = ($signed(ALUin1) < $signed(ALUin2));              //3, signed comparison
        'b0000000011: ALUout = (ALUin1 < ALUin2);                                //4, unsigned comparison
        'b0000000100: ALUout = (ALUin1 ^ ALUin2);                                //5, XOR
        'b0000000101: ALUout = ($signed(ALUin1) >>> ALUin2);                     //6, arithmetic right shift
        'b0100000101: ALUout = (ALUin1 >> ALUin2);                               //7, logical right shift
        'b0000000110: ALUout = (ALUin1 | ALUin2);                                //8, OR
        'b0000000111: ALUout = (ALUin1 & ALUin2);                                //9, AND
        'b0000001000: ALUout = ($signed(ALUin1) * $signed(ALUin2));             //10, mul, multiply signed lower half
        'b0000001001: ALUout = (($signed(ALUin1) * $signed(ALUin2)) >> 32);     //11, mulh, multiply signed upper half
        'b0000001010: ALUout = (($signed(ALUin1) * $unsigned(ALUin2)) >> 32);   //12, mulhsu, multiply signed unsigned upper half 
        'b0000001011: ALUout = (($unsigned(ALUin1) * $unsigned(ALUin2)) >> 32); //13, mulhu, multiply unsigned upper half
        'b0000001100: ALUout = ($signed(ALUin1) / $signed(ALUin2));             //14, div, signed division
        'b0000001101: ALUout = ($unsigned(ALUin1) / $unsigned(ALUin2));         //15, divu, unsigned division
        'b0000001110: ALUout = ($signed(ALUin1) % $signed(ALUin2));             //16, rem, signed remainder
        'b0000001111: ALUout = ($unsigned(ALUin1) % $unsigned(ALUin2));         //17, remu, unsigned remainder
        default: ALUout = 'hffffffff;                                   // Unkown opcode :(
    endcase
end 
endmodule
