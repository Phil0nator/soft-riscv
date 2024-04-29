module notes(input [31:0] instruction);


    wire ALUreginstr = (instruction[6:0] == 7'b0110011);
    wire ALUimminstr = (instruction[6:0] == 7'b0010011);
    wire Branchinstr = (instruction[6:0] == 7'b1100011);
    wire Loadinstr   = (instruction[6:0] == 7'b0000011);
    wire Storeinstr  = (instruction[6:0] == 7'b0100011);
    wire LUIinstr    = (instruction[6:0] == 7'b0110111);
    wire AUIPCinstr  = (instruction[6:0] == 7'b0010111);
    wire JALinstr    = (instruction[6:0] == 7'b1101111);
    wire JALRinstr   = (instruction[6:0] == 7'b1100111);


    wire [4:0] rs1num = instruction[24:20];
    wire [4:0] rs2num = instruction[19:15];
    wire [4:0] rdnum  = instruction[11:7];


//R-type
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
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

/*
    R-Type:
        ALUreg instructions, differentiate with funct3 and funct7
    I-Type:
        ALUimm and JALR,  12-bits sign extension 
    S-Type:
        Store,  12-bits sign extension
    I-Type (loads)
        Load, 12-bits sign extension
    B-type:
        Branch, 12-bits sign extension

//AUIPC to branch
//JAL to branch
//LUI to ALU
//JALR to branch

        
    U-type:
        LUI and AUIPC,  upper 20 bit immediates
    J-type:
        JAL,    12 bits sign extension
*/


/*
    modules to make
    
    R-type              [OK]

    I-type              [OK]

    S-type              [OK]

    B-type

    Memory

    Program counter     [OK]

    phase counter       [OK]





*/

endmodule