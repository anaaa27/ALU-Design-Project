`timescale 1ns/1ps

module alu_top #(parameter WIDTH = 8) (
    input  logic             clk,
    input  logic             reset_n,
    input  logic             start,
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic [3:0]       Opcode,
    
    output logic [WIDTH-1:0] Result,
    output logic             Z, 
    output logic             N, 
    output logic             V, 
    output logic             done
);

    localparam ADD = 4'b0000;
    localparam SUB = 4'b0001;
    localparam MUL = 4'b0010;
    localparam DIV = 4'b0011;
    localparam AND = 4'b0100;
    localparam OR  = 4'b0101;
    localparam XOR = 4'b0110;
    localparam LSH = 4'b0111;
    localparam RSH = 4'b1000;

    logic [WIDTH:0]   add_out, sub_out; 
    logic [15:0]      mul_out, div_out; 
    logic [WIDTH-1:0] ls_and, ls_or, ls_xor, ls_lsh, ls_rsh;
    
    logic mul_done, div_done;
    logic start_mul, start_div;

    // --- Sub-module ---
    adder #(.WIDTH(WIDTH)) u_add (.a(A), .b(B), .cin(1'b0), .en(1'b1), .sum(add_out));
    subtractor #(.WIDTH(WIDTH)) u_sub (.a(A), .b(B), .en(1'b1), .o(sub_out));
    multiplier u_mul (.clk(clk), .reset_n(reset_n), .start(start_mul), .a(A), .b(B), .o(mul_out), .done(mul_done));
    divider u_div (.clk(clk), .reset_n(reset_n), .start(start_div), .a(A), .b(B), .o(div_out), .done(div_done));
    
    logic_shift_unit #(.WIDTH(WIDTH)) u_ls (
        .a(A), .b(B),
        .out_and(ls_and), .out_or(ls_or), .out_xor(ls_xor),
        .out_lsh(ls_lsh), .out_rsh(ls_rsh)
    );

    // --- FSM ---
    typedef enum logic [1:0] {IDLE, BUSY_MUL, BUSY_DIV, FINISH} state_t;
    state_t state, next_state;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) state <= IDLE;
        else          state <= next_state;
    end

    always_comb begin
        next_state = state;
        start_mul = 1'b0;
        start_div = 1'b0;
        done = 1'b0;

        case (state)
            IDLE: begin
                if (start) begin
                    if (Opcode == MUL) begin
                        start_mul = 1'b1;
                        next_state = BUSY_MUL;
                    end else if (Opcode == DIV) begin
                        start_div = 1'b1;
                        next_state = BUSY_DIV;
                    end else begin
                        next_state = FINISH; 
                    end
                end
            end
            BUSY_MUL: if (mul_done) next_state = FINISH;
            BUSY_DIV: if (div_done) next_state = FINISH;
            FINISH: begin
                done = 1'b1;
                next_state = IDLE;
            end
        endcase
    end

    // --- Salvare Securizata a Rezultatului ---
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            Result <= '0;
            V <= 1'b0;
        end else begin
            // Operatii Instantanee (se salveaza cand FSM-ul pleaca din IDLE)
            if (state == IDLE && start) begin
                if (Opcode == ADD) begin Result <= add_out[7:0]; V <= (~A[7] & ~B[7] & add_out[7]) | (A[7] & B[7] & ~add_out[7]); end
                else if (Opcode == SUB) begin Result <= sub_out[7:0]; V <= (~A[7] & B[7] & sub_out[7]) | (A[7] & ~B[7] & ~sub_out[7]); end
                else if (Opcode == AND) begin Result <= ls_and; V <= 0; end
                else if (Opcode == OR)  begin Result <= ls_or; V <= 0; end
                else if (Opcode == XOR) begin Result <= ls_xor; V <= 0; end
                else if (Opcode == LSH) begin Result <= ls_lsh; V <= 0; end
                else if (Opcode == RSH) begin Result <= ls_rsh; V <= 0; end
            end
            // Operatii Secventiale (se salveaza exact in fractiunea de secunda in care sunt gata)
            else if (state == BUSY_MUL && mul_done) begin
                Result <= mul_out[7:0];
                V <= 1'b0;
            end
            else if (state == BUSY_DIV && div_done) begin
                Result <= div_out[15:8];
                V <= 1'b0;
            end
        end
    end

    assign Z = (Result == 8'h00) ? 1'b1 : 1'b0;
    assign N = Result[7];

endmodule