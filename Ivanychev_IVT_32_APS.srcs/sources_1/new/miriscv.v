`include "miriscv_defines.v"
    module miriscv(
    input clk_i,
    input rst
);
//Decoder wires
wire       ws;
wire [2:0] mems;
wire       memwe;
wire       memr;
wire [`ALU_OP_WIDTH-1:0] aop;
wire [1:0] srcA;
wire [2:0] srcB;
wire       rfwe;
wire       jalr;
wire       enpc;
wire       jal;
wire       b;
wire       illegal_instr;
          
//Reg_file wires          
wire [31:0] RD1;
wire [31:0] RD2;
reg  [31:0] WD3;

//Instruction wire
wire [31:0] instr;

//ALU regs and wires
reg [31:0]  operand_a;
reg [31:0]  operand_b;
wire [31:0] alu_res;
wire        comp;

//Data memory wire
wire [31:0] data_memory_o;
//PC reg and wires
reg [31:0] PC;          
reg [31:0] new_PC_f;
reg [31:0] new_PC_alu;

//Imm_X
wire [31:0] imm_I;
assign imm_I = {{20{instr[31]}},instr[31:20]};
wire [31:0] imm_S;
assign imm_S = {{20{instr[11]}},instr[11:0]};
wire [31:0] imm_J;
assign imm_J = {{12{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21]};
wire [31:0] imm_B;
assign imm_B = {{20{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8]};


miriscv_instruction_memory instruction_memory_inst (.adr(PC),
                                                    .rd(instr));
                 
miriscv_register_file register_file_inst (.clk(clk_i),
                                          .rst(rst),
                                          .write_enable(rfwe),
                                          .parametr_adress_a1(instr[19:15]),
                                          .parametr_adress_a2(instr[24:20]),
                                          .parametr_adress_a3(instr[11:7]),
                                          .input_data(WD3),
                                          .parametr_a1(RD1),
                                          .parametr_a2(RD2));
                      
miriscv_alu alu_inst (.operator_i(aop),
                      .operand_a_i(operand_a),
                      .operand_b_i(operand_b),
                      .result_o(alu_res),
                      .comparison_result_o(comp));
                      
miriscv_data_memory data_memory_inst (.clk_i(clk_i),
                                      .address_i(alu_res),
                                      .data_i(RD2),
                                      .access_i(memr),
                                      .we_i(memwe),
                                      .wsize_i(mems),
                                      .data_o(data_memory_o));  
                                                          
miriscv_decode decode_inst (.fetched_instr_i(instr),
                           .ex_op_a_sel_o(srcA),
                           .ex_op_b_sel_o(srcB),
                           .alu_op_o(aop),
                           .mem_req_o(memr),
                           .mem_we_o(memwe),
                           .mem_size_o(mems),
                           .gpr_we_a_o(rfwe),
                           .wb_src_sel_o(ws),
                           .illegal_instr_o(illegal_instr),
                           .branch_o(b),
                           .jal_o(jal),
                           .jarl_o(jalr));
                           
always @(posedge clk_i) begin   
    case (jalr)       
        1'd1: PC = RD1;
        1'd0: 
            case ((comp&b)|jal)
                1'd0: PC <= PC + 4;
                1'd1:
                    case (b)
                        1'd0: PC <= PC + imm_J;
                        1'd1: PC <= PC + imm_B;
                    endcase
            endcase                  
    endcase
end

always @(*) begin
    case (srcA)
        `OP_A_RS1:     operand_a <= RD1;
        `OP_A_CURR_PC: operand_a <= PC;
        `OP_A_ZERO:    operand_a <= 0;
    endcase    
    case (srcB)
        `OP_B_RS2:     operand_b <= RD2;
        `OP_B_IMM_I:   operand_b <= imm_I;
        `OP_B_IMM_U:   operand_b <= {instr[31:12],{12{1'b0}}};
        `OP_B_IMM_S:   operand_b <= imm_B;
        `OP_B_INCR:    operand_b <= 4;
    endcase
    case (ws)
        `WB_EX_RESULT: WD3 <= alu_res;
        `WB_LSU_DATA:  WD3 <= data_memory_o;
    endcase
end

endmodule