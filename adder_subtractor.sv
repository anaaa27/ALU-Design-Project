//--------------------------------------------------------------------------
// Design Name: Adder/Subtractor
// File Name: adder_subtractor.sv
// Description: Adunare, scadere si calculul depasirii (Overflow)
//--------------------------------------------------------------------------
`timescale 1ns/1ps

module adder_subtractor #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] out_add,
    output logic [WIDTH-1:0] out_sub,
    output logic             v_add, // Overflow pentru adunare
    output logic             v_sub  // Overflow pentru scadere
);

    assign out_add = a + b;
    assign out_sub = a - b;

    // Logica pentru Overflow (se uita la bitul de semn, adica bitul 7)
    assign v_add = (~a[WIDTH-1] & ~b[WIDTH-1] & out_add[WIDTH-1]) | (a[WIDTH-1] & b[WIDTH-1] & ~out_add[WIDTH-1]);
    assign v_sub = (~a[WIDTH-1] & b[WIDTH-1] & out_sub[WIDTH-1]) | (a[WIDTH-1] & ~b[WIDTH-1] & ~out_sub[WIDTH-1]);

endmodule