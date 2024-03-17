/*
    This is a binary to seven segment module for the Digilent Basys 3 board that
    takes a positive 16-bit binary value and displays up to 4 digits
    of said number on the 4 on board seven segments
    New data from the BCDin input is only displayed when enable is high
    such that this module could be accessed via a bus
*/
module SevenSegment(
    input clk, //100MHz input clock
    input rst, //reset
    input en, //enables latching in new data
    input [15:0] BCDin, //input value to be displayed
    output reg [3:0] an, //7 segment anode connections
    output reg [0:6] seg //7 segment cathode connections 
                         //all 4 seven segments share cathode connnections
    );
    
reg [19:0] count = 0;
reg [3:0] LED_BCD;
reg [15:0] displayed_number;

//generates count and updates the displayed number from BCDin
// when enable is high
//count is  used to reduce refresh rate from 100MHz clock
//and to select which of the four seven segments is being
//written to
always @ (posedge clk or negedge rst) begin
    if(!rst) begin
        displayed_number <= 0;
        count<=0;
    end else begin
        count <= count + 1;
        if(en) begin
            displayed_number<=BCDin;
        end else begin
            displayed_number<=displayed_number;
        end
    end
end


always @(posedge clk or negedge rst) begin
if(!rst) begin
    an<=4'b1111; //turn off seven segments on reset
end else begin
        case(count[19:18])
            2'b00: begin
                        an = 4'b0111; 
                        // activate seg1 and Deactivate seg2, seg3, seg4
                        LED_BCD = displayed_number/1000;
                        // the first digit of the 16-bit number
                end
            2'b01: begin
                        an = 4'b1011; 
                        // activate seg2 and Deactivate seg1, seg3, seg4
                        LED_BCD = (displayed_number % 1000)/100;
                        // the second digit of the 16-bit number
                end
            2'b10: begin
                        an = 4'b1101; 
                        // activate seg3 and Deactivate seg2, seg1, seg4
                        LED_BCD = ((displayed_number % 1000)%100)/10;
                        // the third digit of the 16-bit number
                    end
            2'b11: begin
                        an = 4'b1110; 
                        // activate seg4 and Deactivate seg2, seg3, seg1
                        LED_BCD = ((displayed_number % 1000)%100)%10;
                        // the fourth digit of the 16-bit number    
                end
        endcase
    end
 end


//BCD case statement
always @(*) begin
        case(LED_BCD)
            4'b0000: seg = 7'b0000001; // "0"     
            4'b0001: seg = 7'b1001111; // "1" 
            4'b0010: seg = 7'b0010010; // "2" 
            4'b0011: seg = 7'b0000110; // "3" 
            4'b0100: seg = 7'b1001100; // "4" 
            4'b0101: seg = 7'b0100100; // "5" 
            4'b0110: seg = 7'b0100000; // "6" 
            4'b0111: seg = 7'b0001111; // "7" 
            4'b1000: seg = 7'b0000000; // "8"     
            4'b1001: seg = 7'b0000100; // "9" 
            default: seg = 7'b0000001; // "0"
        endcase
    end
endmodule