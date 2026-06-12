`timescale 1ns/1ps

module logic_shift_unit #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] out_and,
    output logic [WIDTH-1:0] out_or,
    output logic [WIDTH-1:0] out_xor,
    output logic [WIDTH-1:0] out_lsh,
    output logic [WIDTH-1:0] out_rsh
);

    assign out_and = a & b;
    assign out_or  = a | b;
    assign out_xor = a ^ b;
    assign out_lsh = a << b[2:0]; // Shiftare stânga
    assign out_rsh = a >> b[2:0]; // Shiftare dreapta

endmodule