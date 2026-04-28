//--------------------------------------------------------------------------
// Design Name: Logic Unit
// File Name: logic_unit.sv
// Description: Calculeaza operatiile AND, OR si XOR la nivel de bit
//--------------------------------------------------------------------------
`timescale 1ns/1ps

module logic_unit #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] out_and,
    output logic [WIDTH-1:0] out_or,
    output logic [WIDTH-1:0] out_xor
);

    // Atribuiri continue - calculează instantaneu rezultatele
    assign out_and = a & b;
    assign out_or  = a | b;
    assign out_xor = a ^ b;

endmodule