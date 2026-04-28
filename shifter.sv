//--------------------------------------------------------------------------
// Design Name: Shifter
// File Name: shifter.sv
// Description: Calculeaza shiftarea la stanga si la dreapta
//--------------------------------------------------------------------------
`timescale 1ns/1ps

module shifter #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] a,
    input  logic [2:0]       shift_val, // Primim doar 3 biți din B
    output logic [WIDTH-1:0] out_lsh,
    output logic [WIDTH-1:0] out_rsh
);

    assign out_lsh = a << shift_val;
    assign out_rsh = a >> shift_val;

endmodule