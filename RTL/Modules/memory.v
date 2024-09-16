/*
    This is the MMU for a softcore RISC-V processor designed for the Digilent Basys 3 Board
    It along with all of its supporting modules handle all of the logic necessary for all of the DMA IO
    and other memory mapped features as well as the main program and data memory 

    This IO and features include:
        Program Memory
        General purpose user memory
        LEDs
        7-segments
        buttons
        Switches
        VGA
        64-bit Timer

    Program and general purpose user memory:
        These pieces of memory are byte addressable and support byte, halfword, and word writes and reads that cross the 4-byte memory boundaries
        the size of user memory depends on program memory but the total cumulative size of this part of the memory is 32768 Bytes or 8192 words
        This size is determined in the ram.v file and is easily adjustable
        Program memory should also be loaded using a readmemh command in the ram.v file
        
        This memory uses addresses 0x0040 - 0x8040
    
    LEDs:
        The 16 on board LEDs are controlled using the lowest 16 bits of memory address 0x08

    7-segments:
        The 7-segment output register is at memory address 0x04 and accepts positive 4 digit values up to 9999
        This register handles the binary to BCD conversion so raw binary values will be output properly to the 4 7-segment displays

    buttons:
        4 of the 5 on board buttons are accessible via the 4 lowest bits of address 0x0C, the last button is used as a reset

    Switches:
        The 16 on board switches can be read from the lowest 16 bits  of memory address 0x10

    VGA:
        The VGA control register is at address 0x14 When the lowest bit of this address is 0 the VGA controller reads from
        the VGA buffer at memory 0x100000 - 0x104B00
        When the lowest bit of addres 0x14 is 1 it reads from
        the VGA buffer at memory 0x200000 - 0x204B00
        
        This controller expects 8 bit color with a 2blue - 3red - 3green encoding scheme
        The output frame size is 120 * 160 (width * height)

    64-bit Timer:
            The 64-bit timer has the lowest 32 bits at memory address 0x1C and has the 
            upper 32 bits at memory addres 0x20


*/

module memory(
                input clk,
                input rstn,

                //Core connections
           
                input [31:0] din,  //input data
                input [31:0] addr, //data address
                input wren,        //write enable
                input byte1,       // byte1, halfword, and word are one hot inputs that
                input halfword,    // denote whether the write is a byte, halfword, or word wide
                input word,        //
                output [31:0] dout,//output data

                //Basic IO connections
                input [15:0] switches,
                input [3:0] buttons,
                output reg [15:0] LEDs,
                output [3:0] an, //seven segment anode ports
                output [0:6] seg, //seven segment cathode ports

                //VGA IO
                output Hsync,
                output Vsync,
                output reg [3:0] red,
                output reg [3:0] blue,
                output reg [3:0] green
    );

//wire is high when the input address is within the IO and control register range
wire isIO;
assign isIO = addr < 'h40;

//wire is high when the input address is within the range of memory
wire mem_access;
assign mem_access = ( 'h7FFF > addr) && (addr >= 'h40 ); 

//register always holds the data from the VGA memories
reg [31:0] vga_data;

//register always holds the data from IO and control registers
reg [31:0] IO_dout;

//register always holds the data from the program and user memory
reg [31:0] mem_dout;

//selects whether IO/control, memory, or VGA data is output from the module
assign dout = mem_access ? mem_dout : (isIO ? IO_dout : vga_data);

//------------------------------------------------------------------Program and User Memory Logic--------------------------------------------------------------------------------------------------------------------------------------

wire [31:0] mem_addr;
assign mem_addr = addr - 'h40; //memory address is input address - IO/control registers depth

//ram module connections
reg [31:0] dina;
reg [31:0] dinb;

wire [31:0] douta;
wire [31:0] doutb;

reg [31:0] addrb;
reg [31:0] addra;

reg [3:0] wrena; 
reg [3:0] wrenb;

    ram u0(
                //use synchronous 100MHz clock
                .clka(clk),
                .clkb(clk),
                //memory is always enabled set to high
                .ena(mem_access),
                .enb(mem_access),
                //byte selectable write enables
                .wea(wrena), 
                .web(wrenb),
                //32 bit wide addresses
                .addra(addra),
                .addrb(addrb),
                //32 bit wide input data
                .dina(dina),
                .dinb(dinb),
                //32 bit wide output data
                .douta(douta),
                .doutb(doutb)
                );

wire [1:0] sel;
assign sel = mem_addr[1:0];

//imm1 is used to support writes over 4-byte boundaries using the second port of the true dual port ram
wire [29:0] imm1;
assign imm1 = mem_addr[31:2] + 1;

always @(*) begin
    case(sel)
        2'b00   : begin
                    addra <= {2'b00,mem_addr[31:2]};
                    dina <= din;
                    wrena <= wren ? byte1 ? 4'b0001 : (halfword ? 4'b0011 : (word ? 4'b1111 : 4'b0 )) : 
                             4'b0;
                             
                    mem_dout <= byte1 ? ({{24{1'b0}}, douta[7:0]}) :
                                halfword ? ({{16{1'b0}}, douta[15:0]}) :
                                word ? douta[31:0] : 32'b0;

                    IO_dout <= byte1    ? {{24{1'b0}}, IO_mem[addr[7:2]][7:0]} : 
                               halfword ? {{16{1'b0}}, IO_mem[addr[7:2]][15:0]}  :
                               word     ? IO_mem[addr[7:2]] : 32'b0;
                    
        end
        2'b01   : begin
                    addra <= {2'b00,mem_addr[31:2]};
                    addrb <= {2'b00,imm1};
                    
                    dina <= din << 8;
                    dinb <= din >> 24;
                    
                    wrena <= wren ? byte1 ? 4'b0010 : (halfword ? 4'b0110 : (word ? 4'b1110 : 4'b0 )) : 
                             4'b0;
                    wrenb <= wren ? byte1 ? 4'b0000 : (halfword ? 4'b0000 : (word ? 4'b0001 : 4'b0 )) : 
                             4'b0;
                             
                    mem_dout <= byte1 ? ({{24{1'b0}}, douta[15:8]}) :
                            halfword ? ({{16{1'b0}}, douta[23:8]}) :
                            word ? {doutb[7:0], douta[31:8]} : 32'b0;

                    IO_dout <=  byte1    ? {{24{1'b0}}, IO_mem[addr[7:2]][15:8]} : 
                                halfword ? {{16{1'b0}}, IO_mem[addr[7:2]][23:8]} :
                                word     ? {{8{1'b0}}, IO_mem[addr[7:2]][31:8]}  : 32'b0;

                                    
        end
        2'b10   : begin
                    addra <= {2'b00,mem_addr[31:2]};
                    addrb <= {2'b00,imm1};
                    
                    dina <= din << 16;
                    dinb <= din >> 16;
                    
                    wrena <= wren ? byte1 ? 4'b0100 : (halfword ? 4'b1100 : (word ? 4'b1100 : 4'b0 )) : 
                             4'b0;
                    wrenb <= wren ? byte1 ? 4'b0000 : (halfword ? 4'b0000 : (word ? 4'b0011 : 4'b0 )) : 
                             4'b0;
                             
                    mem_dout <= byte1 ? ({{24{1'b0}}, douta[23:16]}) :
                            halfword ? ({{16{1'b0}}, douta[31:16]}) :
                            word ? {doutb[15:0], douta[31:16]} : 32'b0;



                    IO_dout <=  byte1    ? {{24{1'b0}}, IO_mem[addr[7:2]][23:16]} : 
                                halfword ? {{16{1'b0}}, IO_mem[addr[7:2]][31:16]} :
                                word     ? {{16{1'b0}}, IO_mem[addr[7:2]][31:16]} : 32'b0;
                    
 
        end
        2'b11   : begin
                    addra <= {2'b00,mem_addr[31:2]};
                    addrb <= {2'b00,imm1};
                    
                    dina <= din << 24;
                    dinb <= din >> 8;
                    
                    wrena <= wren ? byte1 ? 4'b1000 : (halfword ? 4'b1000 : (word ? 4'b1000 : 4'b0 )) : 
                             4'b0;
                    wrenb <= wren ? byte1 ? 4'b0000 : (halfword ? 4'b0001 : (word ? 4'b0111 : 4'b0 )) : 
                             4'b0;
                             
                    mem_dout <= byte1 ? ({{24{1'b0}}, douta[31:24]}) :
                            halfword ? ({{16{1'b0}}, {doutb[7:0], douta[31:24]}}) :
                            word ? {doutb[23:0], douta[31:24]} : 32'b0;

                    IO_dout <=  byte1    ? {{24{1'b0}}, IO_mem[addr[7:2]][31:24]} : 
                                halfword ? {{24{1'b0}}, IO_mem[addr[7:2]][31:24]} :
                                word     ? {{24{1'b0}}, IO_mem[addr[7:2]][31:24]} : 32'b0;

        end
        default : begin
            addra <= {2'b00,mem_addr[31:2]};
            addrb <= {2'b00,imm1};
            dina <= 0;
            dinb <= 0;
            wrena <= 0;
            wrenb <= 0;
            mem_dout <= douta;
            IO_dout <= 0;

        end
    endcase
end



//----------------------------------------------------------IO and control registers Logic---------------------------------------------------------------------------------------------------------------------------------------------
reg [15:0] BCDin;

seven_segments u1(.clk(clk),
                  .rstn(rstn),
                  .BCDin(BCDin),
                  .an(an),
                  .seg(seg));

//register bank to map to IO devices
reg [31:0] IO_mem [15:0];

integer IO_mem_init;
initial begin
    for(IO_mem_init = 0; IO_mem_init < 16; IO_mem_init = IO_mem_init + 1) begin
        IO_mem[IO_mem_init] <= 0;
    end
end

reg [63:0] timer0;

wire [1:0] sel2;
assign sel2 = addr[1:0];

always @(posedge clk) begin
    BCDin <= IO_mem[1];
    LEDs <= IO_mem[2];
    case(sel)
    2'b00   : begin

            IO_mem[addr[7:2]] <= isIO ? (wren ? (byte1 ? {IO_mem[addr[7:2]][31:8],din[7:0]} : halfword ? {IO_mem[addr[7:2]][31:16],din[15:0]} : word ? din : IO_mem[addr[7:2]]) : IO_mem[addr[7:2]]) :
                                 IO_mem[addr[7:2]]; 
                                 
    end
    2'b01   : begin
    
        IO_mem[addr[7:2]] <= isIO ? (wren ? (byte1 ? {IO_mem[addr[7:2]][31:16],din[7:0], IO_mem[addr[7:2]][7:0] } : halfword ? {IO_mem[addr[7:2]][31:24],din[15:0], IO_mem[addr[7:2]][7:0]} : word ? {din[23:0], IO_mem[addr[7:2]][7:0]} : IO_mem[addr[7:2]]) : IO_mem[addr[7:2]]) :
                             IO_mem[addr[7:2]];

    end
    2'b10   : begin

        IO_mem[addr[7:2]] <= isIO ? (wren ? (byte1 ? {IO_mem[addr[7:2]][31:24],din[7:0], IO_mem[addr[7:2]][15:0] } : halfword ? {din[15:0], IO_mem[addr[7:2]][15:0]} : word ? {din[15:0], IO_mem[addr[7:2]][15:0]} : IO_mem[addr[7:2]]) : IO_mem[addr[7:2]]) :
                             IO_mem[addr[7:2]];

    end
    2'b11   : begin

        IO_mem[addr[7:2]] <= isIO ? (wren ? (byte1 ? {din[7:0], IO_mem[addr[7:2]][23:0] } : halfword ? {din[7:0], IO_mem[addr[7:2]][23:0]} : word ? {din[7:0], IO_mem[addr[7:2]][23:0]} : IO_mem[addr[7:2]]) : IO_mem[addr[7:2]]) :
                             IO_mem[addr[7:2]];

    end
    default : begin
        IO_mem[addr[7:2]] <= IO_mem[addr[7:2]];
    end
    endcase

    if(!rstn) begin
        timer0 <= 0;
    end else if(!wren) begin
        IO_mem[7] <= timer0[31:0];
        IO_mem[8] <= timer0[63:32];
        timer0 <= timer0 + 1;
    end else if(addr == 'h1C) begin
        IO_mem[7] <= din;
        timer0[31:0] <= din; 
    end else if(addr == 'h20) begin
        IO_mem[8] <= din;
        timer0[63:32] <= din; 
    end
    IO_mem[3] <= buttons;
    IO_mem[4] <= switches;
end

//-----------------------------------------------------------------VGA DMA Controller and memory-------------------------------------------------------------------------------------------------------------------------------------


wire vga_one;
wire vga_two;

assign vga_one = addr[20];
assign vga_two = addr[21];


//VGA memory buffer connections
reg [3:0] vga1_wrena;
reg [3:0] vga2_wrena;

reg [31:0] vga1_addra;
wire [31:0] vga1_addrb;
reg [31:0] vga2_addra;
wire [31:0] vga2_addrb;

reg[31:0] vga1_dina;
reg[31:0] vga2_dina;

wire[31:0] vga1_douta;
wire[31:0] vga1_doutb;
wire[31:0] vga2_douta;
wire[31:0] vga2_doutb;

//VGA buffer 1 instantiation
vga_ram u2(
    //use synchronous 100MHz clock
    .clka(clk),
    .clkb(clk),
    //memory is always enabled set to high
    .ena(vga_one),
    .enb(1'b1),
    //byte selectable write enables
    .wea(vga1_wrena), 
    .web(4'b0),
    //32 bit wide addresses
    .addra(vga1_addra),
    .addrb(vga1_addrb),
    //32 bit wide input data
    .dina(vga1_dina),
    .dinb(32'b0),
    //32 bit wide output data
    .douta(vga1_douta),
    .doutb(vga1_doutb)
    );

//VGA buffer 2 instantiation
vga_ram u3(
    //use synchronous 100MHz clock
    .clka(clk),
    .clkb(clk),
    //memory is always enabled set to high
    .ena(vga_two),
    .enb(1'b1),
    //byte selectable write enables
    .wea(vga2_wrena), 
    .web(4'b0),
    //32 bit wide addresses
    .addra(vga2_addra),
    .addrb(vga2_addrb),
    //32 bit wide input data
    .dina(vga2_dina),
    .dinb(32'b0),
    //32 bit wide output data
    .douta(vga2_douta),
    .doutb(vga2_doutb)
    );

wire newframe;

reg [31:0] vga_dout1;
reg [31:0] vga_dout2;

wire [1:0] sel3;
assign sel3 = addr[1:0];

//VGA H and V sync generator and pixel counter
vga_sync_generator u4(
    .clk(clk), //expects 100MHz input clock
    .rstn(rstn),
    .Hsync(Hsync),
    .newframe(newframe), //high when a new frame is beginning
    .Vsync(Vsync),
    .inframe(inframe), //high when VGA expects pixel data for active display area
    .PxCLK(PCLK) //pixel clock output for synchronization
    );
    
//this block is used to control reading from and writing to the VGA buffers
//it supports byte selectable write enable using the one hot byte1, halfword, and word inputs
always @(*) begin
    case(sel3) 
    2'b00: begin
        vga1_wrena <= wren ? byte1 ? 4'b0001 : (halfword ? 4'b0011 : (word ? 4'b1111 : 4'b0 )) : 
                      4'b0;
        vga2_wrena <= wren ? byte1 ? 4'b0001 : (halfword ? 4'b0011 : (word ? 4'b1111 : 4'b0 )) : 
                      4'b0;
                
        vga1_addra <= {{15{1'b0}} , addr[19:2]};
        vga2_addra <= {{15{1'b0}} , addr[19:2]};

        vga1_dina <= din;
        vga2_dina <= din;

        vga_dout1 <= byte1 ? ({{24{1'b0}}, vga1_douta[7:0]}) :
                     halfword ? ({{16{1'b0}}, vga1_douta[15:0]}) :
                     word ? vga1_douta[31:0] : 32'b0;

        vga_dout2 <= byte1 ? ({{24{1'b0}}, vga2_douta[7:0]}) :
                     halfword ? ({{16{1'b0}}, vga2_douta[15:0]}) :
                     word ? vga2_douta[31:0] : 32'b0;

        vga_data <= vga_one ? vga_dout1 : (vga_two ? vga_dout2 : 32'b0);
    end
    2'b01: begin
        vga1_wrena <= wren ? byte1 ? 4'b0010 : (halfword ? 4'b0110 : (word ? 4'b1110 : 4'b0 )) : 
                      4'b0;
        vga2_wrena <= wren ? byte1 ? 4'b0010 : (halfword ? 4'b0110 : (word ? 4'b1110 : 4'b0 )) : 
                      4'b0;

        vga1_addra <= {{15{1'b0}} , addr[19:2]};
        vga2_addra <= {{15{1'b0}} , addr[19:2]};

        vga1_dina <= din << 8;
        vga2_dina <= din << 8;

        vga_dout1 <= byte1 ? ({{24{1'b0}}, vga1_douta[15:8]}) :
                     halfword ? ({{16{1'b0}}, vga1_douta[23:8]}) :
                     word ? {{8{1'b0}} ,vga1_douta[31:8]} : 32'b0;

        vga_dout2 <= byte1 ? ({{24{1'b0}}, vga2_douta[15:8]}) :
                     halfword ? ({{16{1'b0}}, vga2_douta[23:8]}) :
                     word ? {{8{1'b0}} ,vga2_douta[31:8]} : 32'b0;
    
        vga_data <= vga_one ? vga_dout1 : (vga_two ? vga_dout2 : 32'b0);  
    end
    2'b10: begin
        vga1_wrena <= wren ? byte1 ? 4'b0100 : (halfword ? 4'b1100 : (word ? 4'b1100 : 4'b0 )) : 
                      4'b0;
        vga2_wrena <= wren ? byte1 ? 4'b0100 : (halfword ? 4'b1100 : (word ? 4'b1100 : 4'b0 )) : 
                      4'b0;

        vga1_addra <= {{15{1'b0}} , addr[19:2]};
        vga2_addra <= {{15{1'b0}} , addr[19:2]};

        vga1_dina <= din << 16;
        vga2_dina <= din << 16;

        vga_dout1 <= byte1 ? ({{24{1'b0}}, vga1_douta[23:16]}) :
                     halfword ? ({{16{1'b0}}, vga1_douta[31:16]}) :
                     word ? {{16{1'b0}} ,vga1_douta[31:16]} : 32'b0;

        vga_dout2 <= byte1 ? ({{24{1'b0}}, vga2_douta[23:16]}) :
                     halfword ? ({{16{1'b0}}, vga2_douta[31:16]}) :
                     word ? {{16{1'b0}} ,vga2_douta[31:16]} : 32'b0;

        vga_data <= vga_one ? vga_dout1 : (vga_two ? vga_dout2 : 32'b0);  
    end
    2'b11: begin
        vga1_wrena <= wren ? byte1 ? 4'b1000 : (halfword ? 4'b1000 : (word ? 4'b1000 : 4'b0 )) : 
                      4'b0;
        vga2_wrena <= wren ? byte1 ? 4'b1000 : (halfword ? 4'b1000 : (word ? 4'b1000 : 4'b0 )) : 
                      4'b0;

        vga1_addra <= {{15{1'b0}} , addr[19:2]};
        vga2_addra <= {{15{1'b0}} , addr[19:2]};

        vga1_dina <= din << 24;
        vga2_dina <= din << 24;

        vga_dout1 <= byte1 ? ({{24{1'b0}}, vga1_douta[31:24]}) :
                     halfword ? ({{24{1'b0}}, vga1_douta[31:24]}) :
                     word ? {{24{1'b0}} ,vga1_douta[31:24]} : 32'b0;

        vga_dout2 <= byte1 ? ({{24{1'b0}}, vga2_douta[31:24]}) :
                     halfword ? ({{24{1'b0}}, vga2_douta[31:24]}) :
                     word ? {{24{1'b0}} ,vga2_douta[31:24]} : 32'b0;

        vga_data <= vga_one ? vga_dout1 : (vga_two ? vga_dout2 : 32'b0);  
    end
    default: begin
        vga1_wrena <= 4'b0;
        vga2_wrena <= 4'b0;

        vga1_addra <= 32'b0;
        vga2_addra <= 32'b0;

        vga1_dina <= 32'b0;
        vga2_dina <= 32'b0;

        vga_dout1 <= 32'b0;
        vga_dout2 <= 32'b0;

        vga_data <= 32'b0;
    end
    endcase
end



reg PCLK_delay; //reg used to sample PCLK and detect rising edges
wire [1:0] sel4; //byte select
assign sel4 = count[1:0];

assign vga1_addrb = count[14:2]; //assign vga DMA addresses to count
assign vga2_addrb = count[14:2];

reg [14:0] count; //count used to keep track of which pixel the VGA is on

always @(posedge clk) begin
    PCLK_delay <= PCLK; //delay PCLK to detect rising edges
end

//Block to increment and reset pixel counter
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        count <= 0;
    end else if(newframe) begin
        count <= 0;
    end else if(inframe && PCLK && !PCLK_delay) begin
        count <= count + 1;
    end
end

//block used to determine which byte within the word needs to be output
//only controls VGA color outputs
always @(*) begin
    case(sel4) 
    2'b01: begin
        red[3:1] <= inframe ? (IO_mem[5][0] ? vga2_doutb[5:3] : vga1_doutb[5:3] ) : 
                    3'b000;
        green[3:1] <= inframe ?  (IO_mem[5][0] ? vga2_doutb[2:0] : vga1_doutb[2:0] ) : 
                      3'b000;
        blue [3:2] <= inframe ? (IO_mem[5][0] ? vga2_doutb[7:6] : vga1_doutb[7:6] ): 
                      2'b00;

        red[0] <= 1'b0;
        green[0] <= 1'b0;
        blue[1:0] <= 2'b00;
                            
    end
    2'b10: begin
        red[3:1] <= inframe ? (IO_mem[5][0] ? vga2_doutb[13:11] : vga1_doutb[13:11] ) : 
                    3'b000;
        green[3:1] <= inframe ?  (IO_mem[5][0] ? vga2_doutb[10:8] : vga1_doutb[10:8] ) : 
                      3'b000;
        blue [3:2] <= inframe ? (IO_mem[5][0] ? vga2_doutb[15:14] : vga1_doutb[15:14] ): 
                      2'b00;

        red[0] <= 1'b0;
        green[0] <= 1'b0;
        blue[1:0] <= 2'b00;
    end
    2'b11: begin
        red[3:1] <= inframe ? (IO_mem[5][0] ? vga2_doutb[21:19] : vga1_doutb[21:19] ) : 
                    3'b000;
        green[3:1] <= inframe ?  (IO_mem[5][0] ? vga2_doutb[18:16] : vga1_doutb[18:16] ) : 
                      3'b000;
        blue [3:2] <= inframe ? (IO_mem[5][0] ? vga2_doutb[23:22] : vga1_doutb[23:22] ): 
                      2'b00;

        red[0] <= 1'b0;
        green[0] <= 1'b0;
        blue[1:0] <= 2'b00;
    end
    2'b00: begin
        red[3:1] <= inframe ? (IO_mem[5][0] ? vga2_doutb[29:27] : vga1_doutb[29:27] ) : 
                    3'b000;
        green[3:1] <= inframe ?  (IO_mem[5][0] ? vga2_doutb[26:24] : vga1_doutb[26:24] ) : 
                      3'b000;
        blue [3:2] <= inframe ? (IO_mem[5][0] ? vga2_doutb[31:30] : vga1_doutb[31:30] ): 
                      2'b00;

        red[0] <= 1'b0;
        green[0] <= 1'b0;
        blue[1:0] <= 2'b00;
    end
    default: begin
        red[3:0] <= 4'b0000;
        green[3:0] <= 4'b0000;
        blue[3:0] <= 4'b0000;
    end
    endcase
end

endmodule



