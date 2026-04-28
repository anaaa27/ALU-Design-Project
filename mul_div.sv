//--------------------------------------------------------------------------
// Design Name: Multiplier & Divider
// File Name: mul_div.sv
// Description: Înmulțire pe 8 biți și împărțire cu protecție la 0
//--------------------------------------------------------------------------
`timescale 1ns/1ps

module mul_div #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] out_mul,
    output logic [WIDTH-1:0] out_div
);

    // Înmulțirea standard. Păstrăm doar cei 8 biți de jos.
    assign out_mul = a * b;

    // Bloc pentru împărțire (folosim always_comb pentru condiții)
    always_comb begin
        if (b != 0)
            out_div = a / b;
        else
            out_div = '0; // '0 înseamnă toți biții 0 dacă se încearcă împărțirea la 0
    end

endmodule