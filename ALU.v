module ALU( 

input [4:0] funct,
input [31:0] ALUin1,
input [31:0] ALUin2,

output reg [31:0] ALUout,   
output zeroflag             //active high zero flag

);

assign zeroflag = (ALUout == 0) ? 1 : 0;

always @(*) begin
    case(funct)
        0: ALUout = (ALUin1 + ALUin2);                                //0, addition
        1: ALUout = (ALUin1 - ALUin2);                                //1, subtraction
        2: ALUout = (ALUin1 << ALUin2);                               //2, Logical left shift
        3: ALUout = ($signed(ALUin1) < $signed(ALUin2));              //3, signed comparison
        4: ALUout = (ALUin1 < ALUin2);                                //4, unsigned comparison
        5: ALUout = (ALUin1 ^ ALUin2);                                //5, XOR
        6: ALUout = ($signed(ALUin1) >>> ALUin2);                     //6, arithmetic right shift
        7: ALUout = (ALUin1 >> ALUin2);                               //7, logical right shift
        8: ALUout = (ALUin1 | ALUin2);                                //8, OR
        9: ALUout = (ALUin1 & ALUin2);                                //9, AND
        10: ALUout = ($signed(ALUin1) * $signed(ALUin2));             //10, mul, multiply signed lower half
        11: ALUout = (($signed(ALUin1) * $signed(ALUin2)) >> 32);     //11, mulh, multiply signed upper half
        12: ALUout = (($signed(ALUin1) * $unsigned(ALUin2)) >> 32);   //12, mulhsu, multiply signed unsigned upper half 
        13: ALUout = (($unsigned(ALUin1) * $unsigned(ALUin2)) >> 32); //13, mulhu, multiply unsigned upper half
        14: ALUout = ($signed(ALUin1) / $signed(ALUin2));             //14, div, signed division
        15: ALUout = ($unsigned(ALUin1) / $unsigned(ALUin2));         //15, divu, unsigned division
        16: ALUout = ($signed(ALUin1) % $signed(ALUin2));             //16, rem, signed remainder
        17: ALUout = ($unsigned(ALUin1) % $unsigned(ALUin2));         //17, remu, unsigned remainder
    endcase
end 
endmodule
