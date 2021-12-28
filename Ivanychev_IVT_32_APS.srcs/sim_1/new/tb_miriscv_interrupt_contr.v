`timescale 1ns / 1ps

module tb_miriscv_interrupt_contr();
  parameter     HF_CYCLE = 2.5;       // 200 MHz clock
  parameter     RST_WAIT = 6;         // 10 ns reset
  parameter     RAM_SIZE = 512;       // in 32-bit words
  parameter     CYCLE = 5;

  // clock, reset
  reg           clk;
  reg           rst_n;
  reg [31:0]    mie;
  reg [31:0]    int_req;
  reg           INT_RST;
  
  wire [31:0] mcause;
  wire [31:0] int_fin;
  wire        INT;
  
  miriscv_interrupt_contr contrl_inst(
                                .clk_i(clk),
                                .rst_i(rst_n),
                                .mie_i(mie),
                                .int_req_i(int_req),
                                .INT_RST_i(INT_RST), //Прерывание обработано
                                .mcause_o(mcause),
                                .int_fin_o(int_fin),
                                .INT_o(INT)
  );
  
  initial begin
    clk   = 1'b0;
    rst_n = 1'b1;
    #RST_WAIT;
    rst_n = 1'b0;
    mie = 4'b1000;
    int_req = 4'b0100;
    #CYCLE;
    int_req = 4'b1000;
    #CYCLE
    #CYCLE
       #CYCLE
       
          #CYCLE
             #CYCLE
    INT_RST = 1;
    #CYCLE;
    #CYCLE;
    int_req = 4'b000;
  end
  
  always begin
    #HF_CYCLE;
    clk = ~clk;
  end
endmodule
