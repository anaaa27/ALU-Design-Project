module ALU (
    input  [7:0] A,          // Operandul A (8 biți)
    input  [7:0] B,          // Operandul B (8 biți)
    input  [3:0] Opcode,     // Semnalul de control (4 biți pentru 9 operații)
    output reg [7:0] Result, // Rezultatul (8 biți). Folosim 'reg' pentru că își schimbă valoarea într-un bloc 'always'
    output Z,                // Flag: Zero
    output N,                // Flag: Negativ
    output reg V             // Flag: Overflow
);

    // Definim un "nume" (parametru) pentru fiecare cod de operație ca să fie ușor de citit
    parameter ADD  = 4'b0000;
    parameter SUB  = 4'b0001;
    parameter MUL  = 4'b0010;
    parameter DIV  = 4'b0011;
    parameter AND  = 4'b0100;
    parameter OR   = 4'b0101;
    parameter XOR  = 4'b0110;
    parameter LSH  = 4'b0111; // Left Shift
    parameter RSH  = 4'b1000; // Right Shift

    // Blocul always se execută de fiecare dată când se modifică o intrare (A, B sau Opcode)
    always @(*) begin
        // Setăm Overflow la 0 din oficiu pentru a nu reține valori vechi
        V = 1'b0; 

        case (Opcode)
            ADD: begin
                Result = A + B;
                // Logica pentru Overflow la adunare (Depășire pentru numere cu semn)
                V = (~A[7] & ~B[7] & Result[7]) | (A[7] & B[7] & ~Result[7]);
            end
            SUB: begin
                Result = A - B;
                // Logica pentru Overflow la scădere
                V = (~A[7] & B[7] & Result[7]) | (A[7] & ~B[7] & ~Result[7]);
            end
            MUL: begin
                Result = A * B; 
                // Notă: O înmulțire pe 8 biți generează 16 biți, dar ALU-ul tău cere ieșire pe 8 biți.
                // Prin urmare, păstrăm doar cei mai puțin semnificativi 8 biți.
            end
            DIV: begin
                if (B != 0) 
                    Result = A / B;
                else 
                    Result = 8'h00; // Evităm "crash-ul" împărțirii la 0
            end
            AND: Result = A & B;
            OR:  Result = A | B;
            XOR: Result = A ^ B;
            LSH: Result = A << B[2:0]; // Shiftăm A la stânga cu valoarea primilor 3 biți din B
            RSH: Result = A >> B[2:0]; // Shiftăm A la dreapta
            default: Result = 8'h00;   // Pentru orice alt cod necunoscut, rezultatul e 0
        endcase
    end

    // Calculăm automat celelalte două flag-uri (în afara blocului always)
    // Daca rezultatul este 00000000, Z devine 1. Altfel e 0.
    assign Z = (Result == 8'h00) ? 1'b1 : 1'b0; 
    
    // N devine valoarea celui mai semnificativ bit (bitul 7). Daca e 1, numărul e negativ.
    assign N = Result[7]; 

endmodule