module multiplier (
  input         clk,
  input         reset_n,
  input         start,
  input  [7:0]  a,
  input  [7:0]  b,
  output [15:0] o,
  output        done
);

  // Wires for registers (datapath)
  wire [8:0]  M_reg, M_next;
  wire [17:0] P_reg, P_init, P_mux, P_next, P_shifted;
  wire [2:0]  count_reg, count_next;
  wire [17:0] temp_P_next;
  wire        phase_reg, phase_next; // 1-bit phase: 0 = COMPUTE, 1 = SHIFT

  // M register: load new value when start, else hold.
  assign M_next = start ? {a[7], a} : M_reg;
  dff #(.WIDTH(9)) M_dff (
    .clk(clk),
    .reset_n(reset_n),
    .d(M_next),
    .q(M_reg)
  );
  
  // P register initialization
  assign P_init = {9'b0, b, 1'b0};

  // Phase flip-flop (pipelining the computation)
  dff #(.WIDTH(1)) phase_dff (
    .clk(clk),
    .reset_n(reset_n),
    .d( start ? 1'b0 : ~phase_reg ),
    .q(phase_reg)
  );

  // Multiplexer for P:
  assign P_mux = start ? P_init : ( phase_reg ? P_shifted : P_reg );
  
  dff #(.WIDTH(18)) P_dff (
    .clk(clk),
    .reset_n(reset_n),
    .d(P_mux),
    .q(P_reg)
  );

  // Count register: increment only on SHIFT phase
  wire [2:0] count_plus;
  assign count_plus = count_reg + 3'd1;
  // Reset count on start; increment only when phase==1.
  assign count_next = start ? 3'd0 : ( phase_reg ? count_plus : count_reg );
  dff #(.WIDTH(3)) count_dff (
    .clk(clk),
    .reset_n(reset_n),
    .d(count_next),
    .q(count_reg)
  );
  
  // Datapath: Booth-logic and arithmetic units
  wire [9:0] add_M_result, sub_M_result, add_2M_result, sub_2M_result;
  
  adder #(.WIDTH(9)) add_M_inst (
    .a(P_reg[17:9]),
    .b(M_reg),
    .cin(1'b0),
    .en(1'b1),
    .sum(add_M_result)
  );
  
  subtractor #(.WIDTH(9)) sub_M_inst (
    .a(P_reg[17:9]),
    .b(M_reg),
    .en(1'b1),
    .o(sub_M_result)
  );
  
  wire [8:0] M_shifted;

  leftshifter #(.WIDTH(9)) M_shifted_inst (
    .in(M_reg),
    .serial_in(1'b0),
    .out(M_shifted)
  );
  
  adder #(.WIDTH(9)) add_2M_inst (
    .a(P_reg[17:9]),
    .b(M_shifted),
    .cin(1'b0),
    .en(1'b1),
    .sum(add_2M_result)
  );
  
  subtractor #(.WIDTH(9)) sub_2M_inst (
    .a(P_reg[17:9]),
    .b(M_shifted),
    .en(1'b1),
    .o(sub_2M_result)
  );
  
  booth_selector booth_sel_inst (
    .bits(P_reg[2:0]),
    .add_M(add_M_result[8:0]),
    .add_2M(add_2M_result[8:0]),
    .sub_M(sub_M_result[8:0]),
    .sub_2M(sub_2M_result[8:0]),
    .lower_P(P_reg[8:0]),
    .P(P_reg),
    .temp_P_next(temp_P_next)
  );
  
  dff #(.WIDTH(18)) Pnext_dff (
    .clk(clk),
    .reset_n(reset_n),
    .d( phase_reg ? P_reg : temp_P_next ),
    .q(P_next)
  );
  
  rightshifter2 #(.WIDTH(18)) p_shifter_inst (
    .in(P_next),
    .out(P_shifted)
  );
  
  // Control: done is asserted when count equals 4
  assign done = (count_reg == 3'd4);
  
  // Final output
  assign o = $signed(P_reg[16:1]);
  
endmodule