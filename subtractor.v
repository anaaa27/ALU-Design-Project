module subtractor #(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input              en,
    output [WIDTH:0]   o    // for WIDTH=8, o is 9 bits
);
    // Two's complement subtraction: a - b = a + (~b) + 1 when en is active.
    wire [WIDTH-1:0] b_inv = b ^ {WIDTH{en}};
    wire cin = en;
    wire [WIDTH:0] sum_internal;
    
    adder #(.WIDTH(WIDTH)) u_add (
        .a(a),
        .b(b_inv),
        .cin(cin),
        .en(1'b1),
        .sum(sum_internal)
    );
    
    assign o = { sum_internal[WIDTH-1], sum_internal[WIDTH-1:0] };
endmodule