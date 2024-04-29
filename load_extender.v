

/**
    load_extender is used to determine and execute the necessary sign extension on memory loads.
    (an enable line is included to ensure that signals only change during load instructions
        to save maybe a little bit of power ;) )
*/
module load_extender(
    input en,
    input [31:0] mem_dout,
    input [2:0] funct3,
    output [31:0] data
);

    assign data = en ? (
        funct3 == 'b000 ? 
            ( {{24{mem_dout[7]}}, mem_dout} ) : 
            (
                (
                    funct3 == 'b001 ? 
                    ({{16{mem_dout[15]}}, mem_dout}) : 
                    (data)
                )
            )
        ) : 0;


endmodule