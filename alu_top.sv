//--------------------------------------------------------------------------
// Design Name: ALU Top Level
// File Name: alu_top.sv
// Description: Conectează toate sub-modulele și selectează ieșirea
//--------------------------------------------------------------------------
`timescale 1ns/1ps

module alu_top #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic [3:0]       Opcode,
    output logic [WIDTH-1:0] Result,
    output logic             Z, // Flag Zero
    output logic             N, // Flag Negativ
    output logic             V  // Flag Overflow
);

    // 1. Declarăm "fire" interne pentru a prinde ieșirile din modulele mici
    logic [WIDTH-1:0] res_and, res_or, res_xor;
    logic [WIDTH-1:0] res_lsh, res_rsh;
    logic [WIDTH-1:0] res_add, res_sub;
    logic             v_add, v_sub;
    logic [WIDTH-1:0] res_mul, res_div;

    // 2. Instanțiem piesele de Lego
    logic_unit #(WIDTH) lu_inst (
        .a(A), .b(B),
        .out_and(res_and), .out_or(res_or), .out_xor(res_xor)
    );

    shifter #(WIDTH) sh_inst (
        .a(A), .shift_val(B[2:0]),
        .out_lsh(res_lsh), .out_rsh(res_rsh)
    );

    adder_subtractor #(WIDTH) add_sub_inst (
        .a(A), .b(B),
        .out_add(res_add), .out_sub(res_sub),
        .v_add(v_add), .v_sub(v_sub)
    );

    mul_div #(WIDTH) md_inst (
        .a(A), .b(B),
        .out_mul(res_mul), .out_div(res_div)
    );

    // 3. Definim comenzile pentru claritate
    localparam ADD = 4'b0000;
    localparam SUB = 4'b0001;
    localparam MUL = 4'b0010;
    localparam DIV = 4'b0011;
    localparam AND = 4'b0100;
    localparam OR  = 4'b0101;
    localparam XOR = 4'b0110;
    localparam LSH = 4'b0111;
    localparam RSH = 4'b1000;

    // 4. MUX Gigantic: Alege rezultatul în funcție de Opcode
    always_comb begin
        V = 1'b0; // Default: fără depășire

        case (Opcode)
            ADD: begin Result = res_add; V = v_add; end
            SUB: begin Result = res_sub; V = v_sub; end
            MUL: begin Result = res_mul; end
            DIV: begin Result = res_div; end
            AND: begin Result = res_and; end
            OR:  begin Result = res_or;  end
            XOR: begin Result = res_xor; end
            LSH: begin Result = res_lsh; end
            RSH: begin Result = res_rsh; end
            default: Result = '0;
        endcase
    end

    // 5. Calculăm Flag-urile Z și N la final
    assign Z = (Result == '0);     // 1 dacă toți biții sunt 0
    assign N = Result[WIDTH-1];    // Fix ultimul bit din stânga (bitul de semn)

endmodule