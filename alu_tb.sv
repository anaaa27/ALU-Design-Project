`timescale 1ns/1ps

module alu_tb;
    logic clk;
    logic reset_n;
    logic start;
    logic [7:0] A;
    logic [7:0] B;
    logic [3:0] Opcode;
    
    logic [7:0] Result;
    logic Z, N, V;
    logic done;

    alu_top dut (
        .clk(clk), .reset_n(reset_n), .start(start),
        .A(A), .B(B), .Opcode(Opcode),
        .Result(Result), .Z(Z), .N(N), .V(V), .done(done)
    );

    always #5 clk = ~clk;

    task run_op(input [3:0] op, input [7:0] val_a, input [7:0] val_b, input string op_name);
        begin
            @(negedge clk); 
            A = val_a; B = val_b; Opcode = op;
            start = 1;
            
            @(negedge clk); 
            start = 0;
            
            wait(done == 1'b1);
            @(negedge clk); // Citim dupa ce ceasul s-a potolit
            
            $display("T=%0t | %s | A=%3d B=%3d -> Rezultat=%3d | Z=%b N=%b V=%b", 
                     $time, op_name, A, B, $signed(Result), Z, N, V);
        end
    endtask

    initial begin
        $dumpfile("alu_waves.vcd");
        $dumpvars(0, alu_tb);

        clk = 0; reset_n = 0; start = 0;
        A = 0; B = 0; Opcode = 0;
        
        #15 reset_n = 1; 
        #10;

        $display("--- INCEPERE TESTARE ALU (Final 10) ---");

        run_op(4'b0000, 8'd15,  8'd10, "ADD");
        run_op(4'b0001, 8'd10,  8'd20, "SUB");
        
        run_op(4'b0010, 8'd5,   8'd4,  "MUL"); 
        run_op(4'b0011, 8'd20,  8'd4,  "DIV"); 
        
        run_op(4'b0100, 8'hf0,  8'haa, "AND");
        run_op(4'b0110, 8'hf0,  8'haa, "XOR");
        run_op(4'b0111, 8'd15,  8'd2,  "LSH");
        run_op(4'b0001, 8'd100, 8'd100,"SUB (Flag Z)");

        $display("--- TESTARE FINALIZATA ---");
        $finish;
    end
endmodule