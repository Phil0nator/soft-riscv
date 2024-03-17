/*
  This is a VGA module designed for the digilent Basys 3 FPGA board
  that generates the Vsync and Hsync pulses as well as an inframe flag
  that can be used alongside the pixel clock to coordinate the timing 
  required to drive the color pins of the VGA port
*/

module VGASyncGenerator(
            input clk,           //100MHz Clock
            output reg Hsync,
            output reg Vsync,
            output inframe,      //in frame flag
            output [11:0] Hpos,  //Horizontal Position counter
            output [11:0] Vpos,  //Vertical Position counter
            output pxclk         //25MHz pixel clock
    );


//high when inside of active display area
assign inframe = ((r_VPos < HEIGHT_TOP) & (r_HPos < WIDTH_TOP) & (r_VPos > HEIGHT_BOTTOM) & (r_HPos > WIDTH_BOTTOM)) ? 1 : 0;

    
// generate a 25 MHz pixel clock
// clock_div module doesn't work for some reason
reg [15:0] cnt;
reg PCLK;
assign pxclk = PCLK;
always @(posedge clk)
  {PCLK, cnt} <= cnt + 16'h4000;  // divide by 4: (2^16)/4 = 0x4000
    

//Values pulled from Nandland VGA page / VGA spec
localparam TOTAL_WIDTH = 800;
localparam TOTAL_HEIGHT = 525;
localparam ACTIVE_WIDTH = 640;
localparam ACTIVE_HEIGHT = 480;
localparam H_SYNC_COLUMN = 704;
localparam V_SYNC_LINE = 523;
    
    
    
//values below used to set area of the screen used
//530, 210, 373, and 173 set 320*200 resolution centered on the screen
//470, 270, 433, and 113 set 200*320 resolution, probably better for tetris
//430, 310, 353, and 193 for 120*160 resolution

localparam WIDTH_TOP = 430; //690 for fullscreen
localparam WIDTH_BOTTOM = 310; //50 for fullscreen
localparam HEIGHT_TOP = 353; //513 for fullscreen
localparam HEIGHT_BOTTOM = 193; //33 for fullscreen

    
 
reg [11:0] r_HPos = 0;
reg [11:0] r_VPos = 0;
assign Hpos = r_HPos-310;
assign Vpos = r_VPos-193;
 
//This always block increments the screen position counters
always @(posedge PCLK) begin
  if (r_HPos < TOTAL_WIDTH-1) begin
    r_HPos <= r_HPos + 1;
  end
  else begin
    r_HPos <= 0;
    if (r_VPos < TOTAL_HEIGHT-1) begin
      r_VPos <= r_VPos + 1;
    end
    else begin
      r_VPos <= 0;
    end
  end  
end
 
//This block generates the Hsync signal using the HPos counter
always @(posedge PCLK) begin
  if (r_HPos < H_SYNC_COLUMN) begin
    Hsync = 1'b1;
  end else begin
    Hsync = 1'b0;
  end  
end
 
//This block generates Vsync using the VPos counter
always @(posedge PCLK) begin
  if (r_VPos < V_SYNC_LINE) begin
    Vsync = 1'b1;
  end else begin
    Vsync = 1'b0;
  end  
end   
  
endmodule