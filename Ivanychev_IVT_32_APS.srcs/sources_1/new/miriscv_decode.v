`include "miriscv_defines.v"

module miriscv_decode
(
    input  [31:0] fetched_instr_i,          //Op
    output [1:0] ex_op_a_sel_o,             //srcA  
    output [2:0] ex_op_b_sel_o,             //srcB
    output [`ALU_OP_WIDTH-1:0] alu_op_o,    //aop
    output mem_req_o,                       //
    output mem_we_o,                        //mwe
    output [2:0] mem_size_o,                //
    output gpr_we_a_o,                      //rfwe
    output wb_src_sel_o,                    //wws
    output illegal_instr_o,                 //не отмечен
    output branch_o,                        //b
    output jal_o,                           //jal
    output jarl_o                           //jalr
);

endmodule