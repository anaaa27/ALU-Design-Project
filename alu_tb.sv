`timescale 1ns/1ps

module alu_tb;

    // Semnalele de test
    logic [7:0] A;
    logic [7:0] B;
    logic [3:0] Opcode;
    
    logic [7:0] Result;
    logic Z, N, V;

    // Instanțiem modulul principal ALU
    alu_top #(.WIDTH(8)) dut (
        .A(A), .B(B), .Opcode(Opcode),
        .Result(Result), .Z(Z), .N(N), .V(V)
    );

    initial begin
        // Generăm fișierul pentru formele de undă (GTKWave)
        $dumpfile("alu_waves.vcd");
        $dumpvars(0, alu_tb);

        // Monitorizăm valorile în terminal
        $monitor("Timp=%0t | Op=%b | A=%d, B=%d | Rezultat=%d | Z=%b N=%b V=%b", 
                 $time, Opcode, A, B, Result, Z, N, V);

        $display("--- Incepem testarea ALU ---");

        // Test 1: Adunare (15 + 10 = 25)
        A = 8'd15; B = 8'd10; Opcode = 4'b0000; #10;
        
        // Test 2: Scadere (10 - 20 = -10, ar trebui sa seteze flag-ul N la 1)
        A = 8'd10; B = 8'd20; Opcode = 4'b0001; #10;
        
        // Test 3: Inmultire (5 * 4 = 20)
        A = 8'd5; B = 8'd4; Opcode = 4'b0010; #10;
        
        // Test 4: AND Logic
        A = 8'b11110000; B = 8'b10101010; Opcode = 4'b0100; #10;
        
        // Test 5: Shiftare la stanga (shiftam numarul 15 cu 2 pozitii)
        A = 8'd15; B = 8'd2; Opcode = 4'b0111; #10;
        
        // Test 6: Verificam Flag-ul Zero (Z) prin scadere egala (100 - 100 = 0)
        A = 8'd100; B = 8'd100; Opcode = 4'b0001; #10;

        $display("--- Testare finalizata ---");
        $finish;
    end

endmodule