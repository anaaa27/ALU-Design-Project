module ALU_tb;

    // Definim semnalele de test
    reg [7:0] A;
    reg [7:0] B;
    reg [3:0] Opcode;
    
    wire [7:0] Result;
    wire Z, N, V;

    // Conectăm ALU-ul nostru (Unit Under Test)
    ALU uut (
        .A(A), .B(B), .Opcode(Opcode),
        .Result(Result), .Z(Z), .N(N), .V(V)
    );

    initial begin
        // Această funcție printează automat în terminal de fiecare dată când o valoare se schimbă
        $monitor("Timp=%0t | Op=%b | A=%3d, B=%3d | Rezultat=%3d | Z=%b, N=%b, V=%b", 
                 $time, Opcode, A, B, Result, Z, N, V);
        
        // --- TESTĂM OPERAȚIILE ---
        A = 8'd20; B = 8'd10; // Setăm A=20 și B=10
        
        Opcode = 4'b0000; #10; // ADD (Așteptăm 10 unități de timp)
        Opcode = 4'b0001; #10; // SUB
        Opcode = 4'b0010; #10; // MUL
        Opcode = 4'b0011; #10; // DIV
        
        A = 8'b11001100; B = 8'b10101010; // Schimbăm A și B pentru operații logice
        Opcode = 4'b0100; #10; // AND
        Opcode = 4'b0110; #10; // XOR
        
        A = 8'd8; B = 8'd2;
        Opcode = 4'b0111; #10; // LEFT SHIFT (8 << 2)

        // Testăm un caz care să activeze flag-ul Zero (Z)
        A = 8'd15; B = 8'd15;
        Opcode = 4'b0001; #10; // SUB (15 - 15 = 0)

        $finish; // Oprește simularea
    end

endmodule