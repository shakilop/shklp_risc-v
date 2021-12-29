`timescale 1ns / 1ps

module tb_miriscv_top();

  parameter     HF_CYCLE = 2.5;       // 200 MHz clock
  parameter     RST_WAIT = 6;         // 10 ns reset
  parameter     RAM_SIZE = 2048;       // in 32-bit words

  // clock, reset
  reg clk;
  reg rst_n;
  reg [31:0] int_req;
  wire [31:0] int_fin;
  reg keyboard_clk;
  reg keyboard_data;
  
  reg [5:0] counter; 
  reg [16:0] program = 17'b11111110010101111;
  
  miriscv_top #(
    .RAM_SIZE       ( RAM_SIZE           ),
    .RAM_INIT_FILE  ( "program_lab7.txt" )
  ) dut (
    .clk_i    ( clk   ),
    .rst_n_i  ( rst_n ),
    .keyboard_data_i(keyboard_data),
    .keyboard_clk_i(keyboard_clk)
//    .int_req_i( int_req ),
//    .int_fin_o( int_fin )
  );

  initial begin
    counter = 0;
    clk   = 1'b0;
    rst_n = 1'b1;
    keyboard_clk = 1'b1;
    keyboard_data = 1'b1;
    int_req = 1'b0;
    #RST_WAIT;
    rst_n = 1'b0;
    

  end

  always @(*) begin
    if (int_fin) begin
        #HF_CYCLE
        int_req <= 0;
    end
  end

  always begin
    for (counter = 0; counter < 63; counter = counter + 1) begin
        #HF_CYCLE;
        clk = ~clk;
    end
    keyboard_clk = ~keyboard_clk; 
  end

  always @(negedge keyboard_clk) begin
    keyboard_data = program[0];
    program = program >> 1;
  end

endmodule
