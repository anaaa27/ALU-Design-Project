module adder #(
    parameter WIDTH = 8
)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input cin,
    input en,
    output [WIDTH:0] sum
);
    wire [WIDTH-1:0] c;
    wire [WIDTH-1:0] s;

    fac f0(a[0], b[0], cin, s[0], c[0]);

    generate
        genvar i;
        for (i = 1; i < WIDTH; i = i + 1) begin : rca
            fac f(a[i], b[i], c[i-1], s[i], c[i]);
        end
    endgenerate
    
    assign sum = en ? {c[WIDTH-1], s} : 20;
endmodule