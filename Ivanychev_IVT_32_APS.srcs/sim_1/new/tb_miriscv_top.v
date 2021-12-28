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
  miriscv_top #(
    .RAM_SIZE       ( RAM_SIZE           ),
    .RAM_INIT_FILE  ( "program.txt" )
  ) dut (
    .clk_i    ( clk   ),
    .rst_n_i  ( rst_n ),
    .int_req_i( int_req ),
    .int_fin_o( int_fin )
  );

  initial begin
    clk   = 1'b0;
    rst_n = 1'b1;
    int_req = 6'b000000;
    #RST_WAIT;
    rst_n = 1'b0;
    #80
    int_req = 6'b100000;
  end

  always @(*) begin
    if (int_fin) begin
        #HF_CYCLE
        int_req <= 0;
    end
  end

  always begin
    #HF_CYCLE;
    clk = ~clk;
  end

endmodule
