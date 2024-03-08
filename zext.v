

module zext #(parameter A = 7, parameter Q = 7) (
    input [A:0] a,
    output [Q:0] q
);

    assign q = {(Q-A){0}, a};

endmodule