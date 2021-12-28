`include "miriscv_defines.v"

//core (
//    .clk_i   ( clk_i   ),
//    .arstn_i ( rst_n_i ),

//    .instr_rdata_i ( instr_rdata_core ),
//    .instr_addr_o  ( instr_addr_core  ),

//    .data_rdata_i  ( data_rdata_core  ),
//    .data_req_o    ( data_req_core    ),
//    .data_we_o     ( data_we_core     ),
//    .data_be_o     ( data_be_core     ),
//    .data_addr_o   ( data_addr_core   ),
//    .data_wdata_o  ( data_wdata_core  )
//  );


module miriscv_core(
    input clk_i,
    input arstn_i,
    
    //Instruction interface
    input  [31:0]   instr_rdata_i,
    output [31:0]   instr_addr_o,
    
    //Data interface
    input [31:0]    data_rdata_i,
    output          data_req_o,
    output          data_we_o,
    output [3:0]    data_be_o,
    output [31:0]   data_addr_o,
    output [31:0]   data_wdata_o,
    
    //interruption interface
    input           int_i,
    input [31:0]    mcause_i,
    output          int_rst_o,
    output [31:0]   mie_o
    
);
//Decoder wires
wire       dec_stall;
wire       dec_ws;
wire [2:0] dec_mems;
wire       dec_memwe;
wire       dec_memr;
wire [`ALU_OP_WIDTH-1:0] dec_aop;
wire [1:0] dec_srcA;
wire [2:0] dec_srcB;
wire       dec_register_file_we;
wire [1:0] dec_jalr;
wire       dec_enpc;
wire       dec_jal;
wire       dec_b;
wire       dec_illegal_instr;
wire       dec_csr;
wire [2:0] dec_csrop;
wire       dec_int_rst;    
wire       dec_int;
//Reg_file wires          
wire [31:0] register_file_RD1;
wire [31:0] register_file_RD2;
reg  [31:0] register_file_WD3;
wire        register_file_we;

//CSR wires
wire [31:0] csr_mie;
wire [31:0] csr_mtvec;
wire [31:0] csr_mepc;
wire [31:0] csr_rd;
wire [31:0] csr_wd;
wire [11:0] csr_a;
wire [2:0] csr_op;
wire [31:0] csr_pc;
wire [31:0] csr_mcause;
//Instruction wire
wire [31:0] instr;

//ALU regs and wires
wire [`ALU_OP_WIDTH-1:0] alu_operator;
reg [31:0]  alu_operand_a;
reg [31:0]  alu_operand_b;
wire [31:0] alu_res;
wire        alu_comp;

//PC reg and wires
reg [31:0] PC;          

//LSU wires
wire [31:0] lsu_addr;
wire        lsu_we;
wire [2:0]  lsu_size;
wire [31:0] lsu_data_i;
wire [31:0] lsu_data_o;
wire        lsu_req;
wire        lsu_stall;
wire [31:0] data_rdata;
//Imm_X
wire [31:0] imm_I;
assign imm_I = {{20{instr[31]}},instr[31:20]};
wire [31:0] imm_S;
assign imm_S = {{20{instr[31]}},instr[31:25],instr[11:7]};
wire [31:0] imm_J;
assign imm_J = {{12{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21]} << 1;
wire [31:0] imm_B;
assign imm_B = {{20{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8]} << 1;

//assigns
assign instr = instr_rdata_i;
assign instr_addr_o = PC;
assign alu_operator = dec_aop;
assign register_file_we = dec_register_file_we;
assign data_rdata = data_rdata_i;
assign lsu_addr = alu_res;
assign lsu_we = dec_memwe;
assign lsu_size = dec_mems;             
assign lsu_data_i = register_file_RD2;
assign lsu_req = dec_memr;
assign dec_stall = lsu_stall;
assign csr_a = instr[31:20];
assign csr_wd = register_file_RD1;
assign csr_op = dec_csrop;
assign csr_mcause = mcause_i;
assign csr_pc = PC;
assign mie_o = csr_mie;
assign int_rst_o = dec_int_rst;
assign dec_int = int_i;


miriscv_csr control_status_registers (  .clk_i(clk_i),
                                        .A_i(csr_a),
                                        .WD_i(csr_wd),
                                        .OP_i(csr_op),
                                        .mcause_i(csr_mcause),
                                        .PC_i(csr_pc),
                                        .mie_o(csr_mie),
                                        .mtvec_o(csr_mtvec),
                                        .mepc_o(csr_mepc),
                                        .RD_o(csr_rd)
);

miriscv_register_file register_file_inst (.clk(clk_i),
                                          .rst(arstn_i),
                                          .write_enable(register_file_we),
                                          .parametr_adress_a1(instr[19:15]),
                                          .parametr_adress_a2(instr[24:20]),
                                          .parametr_adress_a3(instr[11:7]),
                                          .input_data(register_file_WD3),
                                          .parametr_a1(register_file_RD1),
                                          .parametr_a2(register_file_RD2));
                      
miriscv_alu alu_inst (.operator_i(alu_operator),
                      .operand_a_i(alu_operand_a),
                      .operand_b_i(alu_operand_b),
                      .result_o(alu_res),
                      .comparison_result_o(alu_comp));
                      
                                                          
miriscv_decode decode_inst (.fetched_instr_i(instr),
                            .int_i(dec_int),
                            .stall_i(dec_stall),
                            .ex_op_a_sel_o(dec_srcA),
                            .ex_op_b_sel_o(dec_srcB),
                            .alu_op_o(dec_aop),
                            .mem_req_o(dec_memr),
                            .mem_we_o(dec_memwe),
                            .mem_size_o(dec_mems),
                            .gpr_we_a_o(dec_register_file_we),
                            .wb_src_sel_o(dec_ws),
                            .illegal_instr_o(dec_illegal_instr),
                            .branch_o(dec_b),
                            .jal_o(dec_jal),
                            .jalr_o(dec_jalr),
                            .enpc_o(dec_enpc),
                            .csr_o(dec_csr),
                            .csrop_o(dec_csrop),
                            .int_rst_o(dec_int_rst));
                            
miriscv_lsu lsu_inst(.clk_i(clk_i),
            .arstn_i(arstn_i),
            .lsu_addr_i(lsu_addr),
            .lsu_we_i(lsu_we),
            .lsu_size_i(lsu_size),
            .lsu_data_i(lsu_data_i),
            .lsu_req_i(lsu_req),
            .lsu_stall_req_o(lsu_stall),
            .lsu_data_o(lsu_data_o),
            .data_rdata_i(data_rdata),
            .data_req_o(data_req_o),
            .data_we_o(data_we_o),
            .data_be_o(data_be_o),
            .data_addr_o(data_addr_o),
            .data_wdata_o(data_wdata_o)  
);
                           
always @(posedge clk_i) begin
    if (arstn_i) begin
        PC <= 0;
    end
    if (dec_enpc)   
        case (dec_jalr)
            2'd3: PC <= csr_mtvec;
            2'd2: PC <= csr_mepc;       
            2'd1: PC <= register_file_RD1;
            2'd0: 
                case ((alu_comp&&dec_b)|dec_jal)
                    1'd0: PC <= PC + 4;
                    1'd1:
                        case (dec_b)
                            1'd0: PC <= PC + imm_J;
                            1'd1: PC <= PC + imm_B;
                        endcase
                endcase                  
        endcase
end

always @(*) begin
    case (dec_srcA)
        `OP_A_RS1:     alu_operand_a <= register_file_RD1;
        `OP_A_CURR_PC: alu_operand_a <= PC;
        `OP_A_ZERO:    alu_operand_a <= 0;
    endcase    
    case (dec_srcB)
        `OP_B_RS2:     alu_operand_b <= register_file_RD2;
        `OP_B_IMM_I:   alu_operand_b <= imm_I;
        `OP_B_IMM_U:   alu_operand_b <= {instr[31:12],{12{1'b0}}};
        `OP_B_IMM_S:   alu_operand_b <= imm_S;
        `OP_B_INCR:    alu_operand_b <= 4;
    endcase
    case (dec_csr)
        1'b1:register_file_WD3 <= csr_rd;
        1'b0:
            case (dec_ws)
                `WB_EX_RESULT: register_file_WD3 <= alu_res;
                `WB_LSU_DATA:  register_file_WD3 <= lsu_data_o;
            endcase
    endcase
end

endmodule