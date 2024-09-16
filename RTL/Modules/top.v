`include "constants.v"

module top(
    input RST,
    input CLK,
    input [15:0] SWITCHES,
    input [3:0] BUTTONS,
    output Hsync,
    output Vsync,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue,
    output [15:0] LEDS,
    output [3:0] SEG7_ANODE,
    output [0:6] SEG7_CATHODE

);
    

    wire rstn;
    assign rstn = !RST;
    wire clk;
    assign clk = CLK;

    wire phase_fetch, phase_execute, phase_commit;
    phase_counter phaser(clk, rstn, phase_fetch, phase_execute, phase_commit);

    wire [31:0] pc_offset;
    wire pc_offset_en;
    wire [31:0] pc;
    wire pc_override;
    program_counter pctr(clk, rstn, pc_offset, pc_offset_en, pc_override, phase_execute, phase_commit, pc);


    

    reg [31:0] instruction;
    wire ALUreginstr = (instruction[6:0] == 7'b0110011);
    wire ALUimminstr = (instruction[6:0] == 7'b0010011);
    wire Branchinstr = (instruction[6:0] == 7'b1100011);
    wire Loadinstr   = (instruction[6:0] == 7'b0000011);
    wire Storeinstr  = (instruction[6:0] == 7'b0100011);
    wire LUIinstr    = (instruction[6:0] == 7'b0110111);
    wire AUIPCinstr  = (instruction[6:0] == 7'b0010111);
    wire JALinstr    = (instruction[6:0] == 7'b1101111);
    wire JALRinstr   = (instruction[6:0] == 7'b1100111);

    // combinational type of instruction to include branches, and other misc. instructions
    // that we decided to include in the branch instruction logic
    wire Branchtype_instr = (Branchinstr || JALinstr || JALRinstr);
    

    wire [4:0] rs1num = instruction[19:15];
    wire [4:0] rs2num = instruction[24:20];
    wire [4:0] rdnum  = instruction[11:7];


    //R-type
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    // ensure funct7 is 0x00 for alu imm instructions
    wire [6:0] funct7_alu = (ALUreginstr ? funct7 : 0);
    //I-type
    wire [31:0] Iimmediate = {{21{instruction[31]}}, instruction[30:20]};
    //also uses funct3
    //S-type
    wire [31:0] Simmediate = {{21{instruction[31]}}, instruction[30:25],instruction[11:7]};
    //also uses funct3
    //B-type
    wire [31:0] Bimmediate  = {{20{instruction[31]}}, instruction[7],instruction[30:25],instruction[11:8],1'b0};
    //also uses funct3
    //U-type
    wire [31:0] Uimmediate = {instruction[31],instruction[30:12], {12{1'b0}}};
    //J-type
    wire [31:0] Jimmediate  = {{12{instruction[31]}}, instruction[19:12],instruction[20],instruction[30:21],1'b0};

    // reg reg_wen;
    // reg [31:0] reg_data; 
    // wire [31:0] rs1;
    // wire [31:0] rs2;
    // riscv_registers registers( clk, rstn, rs1num, rs2num, rdnum, reg_wen, reg_data, rs1, rs2);


    reg [31:0] registers [31:0];
    integer rdumper;
    initial begin
        for (rdumper = 0; rdumper < 32; rdumper = rdumper + 1) $dumpvars(0, registers[rdumper]);
    end


    reg [31:0] ALUin1;
    reg [31:0] ALUin2;
    wire [31:0] ALUout;
    alu ALU(
        clk,
        funct3,
        funct7_alu,
        ALUin1,
        ALUin2,
        ALUout
    );

    reg [31:0] old_test_memory [6:0];
    initial begin


        /*
    

// origin (0x20)
    addi x1, zero, 5
    addi x2, zero, 4
loop:
    add x3, x3, x2
    addi x1, x1, -1
    bne x1, zero, loop
    
    jalr x1, zero, 0x34     // halt



        */
        old_test_memory [0] <= 'h00500093;
        old_test_memory [1] <= 'h00400113;
        old_test_memory [2] <= 'h002181b3;
        old_test_memory [3] <= 'hfff08093;
        old_test_memory [4] <= 'hfe009ce3;      
        old_test_memory [5] <= 'h034000e7; 

    end




    reg [31:0] mem_address;
    reg mem_write;
    wire [31:0] mem_dout;
    reg [31:0] mem_din;
    reg mem_byte;
    reg mem_halfword;
    reg mem_word;



    // old_test_memory

    // wire [31:0] mem_data_loaded;
    // load_extender lextdr(Loadinstr, mem_dout, funct3, mem_data_loaded);


    // branching instructions
    branch_instructions brinstrs(
        Branchtype_instr,
        funct3,
        JALinstr,
        JALRinstr,
        Branchinstr,
        
        registers[rs1num],
        registers[rs2num],
        
        Bimmediate,
        Jimmediate,
        Iimmediate,


        pc_offset_en,
        pc_offset,
        pc_override
    );

    memory mem(
        clk,
        rstn,

        //Core connections
        mem_din,
        mem_address,
        mem_write,
        mem_byte,
        mem_halfword,
        mem_word,
        mem_dout,

        //Basic IO connections
        SWITCHES,
        BUTTONS,
        LEDS,
        SEG7_ANODE, //seven segment anode ports
        SEG7_CATHODE, //seven segment cathode ports

        //VGA IO
        Hsync,
        Vsync,
        red,
        blue,
        green
    );

    reg [31:0] pc_temp = 0;
    

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            instruction <= 0;
            mem_byte <= 0;
            mem_halfword <= 0;
            mem_word <= 1;
            mem_address <= `PROGRAM_BASE_ADDR;
            pc_temp <= 0;
            mem_write <= 0;
            mem_din <= 0;

            registers[0] <= 0;
            registers[1] <= 0;
            registers[2] <= 0;
            registers[3] <= 0;
            registers[4] <= 0;
            registers[5] <= 0;
            registers[6] <= 0;
            registers[7] <= 0;
            registers[8] <= 0;
            registers[9] <= 0;
            registers[10] <= 0;
            registers[11] <= 0;
            registers[12] <= 0;
            registers[13] <= 0;
            registers[14] <= 0;
            registers[15] <= 0;
            registers[16] <= 0;
            registers[17] <= 0;
            registers[18] <= 0;
            registers[19] <= 0;
            registers[20] <= 0;
            registers[21] <= 0;
            registers[22] <= 0;
            registers[23] <= 0;
            registers[24] <= 0;
            registers[25] <= 0;
            registers[26] <= 0;
            registers[27] <= 0;
            registers[28] <= 0;
            registers[29] <= 0;
            registers[30] <= 0;
            registers[31] <= 0;

        end else begin
            
            if (phase_fetch) begin
                



                instruction <= mem_dout;


                // load instructions need to load memory address early
                if ((mem_dout[6:0] == 7'b0000011)) begin
                    mem_address <= registers[mem_dout[19:15]] + {{21{mem_dout[31]}}, mem_dout[30:20]};
                    mem_byte <= (mem_dout[13:12] == 0);
                    mem_halfword <= (mem_dout[13:12] == 1);
                    mem_word <= (mem_dout[13:12] == 2);
                end 
               

            end else if (phase_execute) begin

                
                if (Loadinstr || Storeinstr) begin
                    mem_byte <= (funct3[1:0] == 0);
                    mem_halfword <= (funct3[1:0] == 1);
                    mem_word <= (funct3[1:0] == 2);
                end else begin
                    
                end

                if (ALUreginstr) begin
                    ALUin1 <= registers[rs1num];
                    ALUin2 <= registers[rs2num];
                end else if (ALUimminstr) begin
                    ALUin1 <= registers[rs1num];
                    ALUin2 <= Iimmediate;
                end else if (Storeinstr) begin
                    mem_address <= registers[rs1num] + Simmediate;
                    mem_din <= registers[rs2num];
                    mem_write <= 1;
                end else if (JALinstr || JALRinstr) begin
                    pc_temp <= pc + 4;
                end else if (AUIPCinstr) begin
                    registers[rdnum] <= pc + Uimmediate;
                end else if (LUIinstr) begin
                    registers[rdnum] <= Uimmediate;
                end else if (Loadinstr) begin
                    // mem_address <= registers[rs1num] + Iimmediate;
                end else begin
                    
                end


            end else if (phase_commit) begin
                
                if (Storeinstr) begin
                    // mem_write <= 1;
                end else if (JALinstr || JALRinstr) begin
                    if (rdnum) begin
                        registers[rdnum] <= pc_temp;
                    end else begin
                        registers[0] <= 0;
                    end
                end else begin
                    
                end

                if (Loadinstr) begin
                    if (rdnum) begin
                        if (funct3 == 0) begin
                            registers[rdnum] <= {{24{mem_dout[7]}}, mem_dout};
                        end else if (funct3 == 1) begin
                            registers[rdnum] <= {{16{mem_dout[15]}}, mem_dout};
                        end else begin
                            registers[rdnum] <= mem_dout;
                        end
                    end else begin
                        registers[0] <= 0;
                    end
                end else begin
                    
                end
                

                // setup memory read for fetch phase
                mem_address <= pc;
                mem_write <= 0;
                mem_word <= 1;
                mem_byte <= 0;
                mem_halfword <= 0;
            end else begin
                

                if (ALUreginstr || ALUimminstr) begin
                    
                    if (rdnum) begin
                        registers[rdnum] <= ALUout;
                    end else begin
                        registers[0] <= 0;
                    end

                end else begin
                    
                end

                

                
            end



        end
    end

endmodule
