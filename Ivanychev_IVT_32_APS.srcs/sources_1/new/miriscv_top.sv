module miriscv_top
#(
  parameter RAM_SIZE      = 256, // bytes
  parameter RAM_INIT_FILE = ""
)
(
  // clock, reset
  input clk_i,
  input rst_n_i,
  
  //input [31:0] int_req_i,
  //output [31:0] int_fin_o,
  
  input keyboard_clk_i,
  input keyboard_data_i
);

  logic  [31:0]  instr_rdata_core;
  logic  [31:0]  instr_addr_core;

  logic  [31:0]  data_rdata_core;
  logic          data_req_core;
  logic          data_we_core;
  logic  [3:0]   data_be_core;
  logic  [31:0]  data_addr_core;
  logic  [31:0]  data_wdata_core;

  logic  [31:0]  data_rdata_ram;
  logic          data_req_ram;
  logic          data_we_ram;
  logic  [3:0]   data_be_ram;
  logic  [31:0]  data_addr_ram;
  logic  [31:0]  data_wdata_ram;
  
  wire [31:0] mie;
  wire INT;
  wire INT_RST;
  wire [31:0] mcause;
  
  wire data_we;
  wire data_req;
 
  wire [7:0] keyboard_data;
  wire       keyboard_valid_data;
  
  wire [31:0] keyboard_reg_data;
  
  wire [1:0] RDsel;
  
  wire LED_we;
  wire [31:0] LED_data;
  
  wire   keyboard_int;
  wire   keyboard_int_rst;
  
  wire [31:0] interrupt_contr_req = {31'b0,keyboard_int};
  
  logic  data_mem_valid;
  assign data_mem_valid = (data_addr_core >= RAM_SIZE) ?  1'b0 : 1'b1;

  //assign data_rdata_core  = (data_mem_valid) ? data_rdata_ram : 1'b0;
  assign data_req_ram     = (data_mem_valid) ? data_req_core : 1'b0;
  assign data_we_ram      =  data_we_core;
  assign data_be_ram      =  data_be_core;
  assign data_addr_ram    =  data_addr_core;
  assign data_wdata_ram   =  data_wdata_core;
  
  LED_reg LED_reg_inst(
    .clk_i(clk_i),
    .rstn_i(rst_n_i),
    .addr_i(data_addr_ram),
    .data_i(data_wdata_ram),
    .be_i(data_be_ram),    ////////////
    .we_i(LED_we),
    .data_o(LED_data)
  );
  
  miriscv_keyboard_reg keyboard_reg(
    .clk_i(clk_i),
    .rstn_i(rst_n_i),
    .valid_data_i(keyboard_valid_data),
    .data_i(keyboard_data),
    .int_fin_i(keyboard_int_rst),
    .int_req_o(keyboard_int),
    .data_o(keyboard_reg_data)
    
  );
  
  ps2_keyboard keyboard_inst(
    .areset(rst_n_i),
    .clk_50(clk_i),
    .ps2_clk(keyboard_clk_i),
    .ps2_dat(keyboard_data_i),
    .valid_data(keyboard_valid_data),
    .data(keyboard_data)
  );
  
  miriscv_address_decoder address_decoder_inst (
    .addr_i     (data_addr_ram),
    .we_i       (data_we_core),
    .req_i      (data_req_core),
    .we_mem_o   (data_we),
    .req_mem_o  (data_req),
    .we_d0_o    (),
    .we_d1_o    (LED_we),
    .RDsel_o    (RDsel)
  );
  
  miriscv_interrupt_contr interrupt_contr_inst (.clk_i(clk_i),
    .rst_i      (   rst_n_i     ),
    .mie_i      (   mie         ),
    .int_req_i  (   {31'b0,keyboard_int}   ),
    .INT_RST_i  (   INT_RST     ),
    .mcause_o   (   mcause      ),
    .int_fin_o  (   keyboard_int_rst   ),
    .INT_o      (   INT         )
  );
  
  
  
  miriscv_core core (
    .clk_i   ( clk_i   ),
    .arstn_i ( rst_n_i ),

    .instr_rdata_i ( instr_rdata_core ),
    .instr_addr_o  ( instr_addr_core  ),

    .data_rdata_i  ( data_rdata_core  ),
    .data_req_o    ( data_req_core    ),
    .data_we_o     ( data_we_core     ),
    .data_be_o     ( data_be_core     ),
    .data_addr_o   ( data_addr_core   ),
    .data_wdata_o  ( data_wdata_core  ),
    
    .int_i(INT),
    .mcause_i(mcause),
    .int_rst_o(INT_RST),
    .mie_o(mie)
  );

  miriscv_ram
  #(
    .RAM_SIZE      (RAM_SIZE),
    .RAM_INIT_FILE (RAM_INIT_FILE)
  ) ram (
    .clk_i   ( clk_i   ),
    .rst_n_i ( !rst_n_i ),

    .instr_rdata_o ( instr_rdata_core ),
    .instr_addr_i  ( instr_addr_core  ),

    .data_rdata_o  ( data_rdata_ram  ),
    .data_req_i    ( data_req        ),
    .data_we_i     ( data_we         ),
    .data_be_i     ( data_be_ram     ),
    .data_addr_i   ( data_addr_ram   ),
    .data_wdata_i  ( data_wdata_ram  )
  );

  always @(*) begin
    case(RDsel)
        2'd0: data_rdata_core <= data_rdata_ram;
        2'd1: data_rdata_core <= keyboard_reg_data;
        2'd2: data_rdata_core <= LED_data;
    endcase
  end

endmodule
