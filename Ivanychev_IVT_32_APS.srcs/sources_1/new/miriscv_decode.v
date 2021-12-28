`include "miriscv_defines.v"

module miriscv_decode
(
    input  [31:0]               fetched_instr_i,            //Op
    input                       stall_i,
    input                       int_i,
    output [1:0]                ex_op_a_sel_o,              //srcA  
    output [2:0]                ex_op_b_sel_o,              //srcB
    output [`ALU_OP_WIDTH-1:0]  alu_op_o,                   //aop
    output                      mem_req_o,                  //memi
    output                      mem_we_o,                   //mwe
    output [2:0]                mem_size_o,                 //memi
    output                      gpr_we_a_o,                 //rfwe
    output                      wb_src_sel_o,               //ws
    output                      illegal_instr_o,            //не отмечен
    output                      branch_o,                   //b
    output                      jal_o,                      //jal
    output [1:0]                jalr_o,                     //jalr
    output                      enpc_o,
    output                      csr_o,
    output [2:0]                csrop_o,
    output                      int_rst_o
);

reg [1:0]               ex_op_a_sel;
reg [2:0]               ex_op_b_sel;
reg [`ALU_OP_WIDTH-1:0] alu_op;
reg                     mem_req;
reg                     mem_we;
reg [2:0]               mem_size;
reg                     gpr_we_a;
reg                     wb_src_sel;
reg                     illegal_instr;
reg                     branch;
reg                     jal;
reg [1:0]               jarl;
reg                     csr;
reg [2:0]               csrop;
reg                     int_rst;


assign ex_op_a_sel_o = ex_op_a_sel;
assign ex_op_b_sel_o = ex_op_b_sel;
assign alu_op_o = alu_op;
assign mem_req_o = mem_req;
assign mem_we_o = mem_we;
assign mem_size_o = mem_size;
assign gpr_we_a_o = gpr_we_a;
assign wb_src_sel_o = wb_src_sel;
assign illegal_instr_o = illegal_instr;
assign branch_o = branch;
assign jal_o = jal;
assign jalr_o = jarl;
assign enpc_o = !stall_i;
assign csr_o = csr;
assign csrop_o = csrop;
assign int_rst_o = int_rst;


always @(*) begin
    if (!int_i) begin
        if (fetched_instr_i[1:0]==2'b11) begin
            case (fetched_instr_i[6:2]) 
                `LOAD_OPCODE: begin
                    if (fetched_instr_i[14:12]<=5 && fetched_instr_i[14:12]!=3) begin
                        ex_op_a_sel <= `OP_A_RS1;
                        ex_op_b_sel <= `OP_B_IMM_I;
                        alu_op <= `ALU_ADD;
                        mem_req <= 1;
                        mem_we <= 0;
                        mem_size <= fetched_instr_i[14:12];
                        gpr_we_a <= 1;
                        wb_src_sel <= `WB_LSU_DATA;
                        illegal_instr <= 0;
                        branch <= 0;
                        jal <= 0;
                        jarl <= `PC_INC;
                        csrop <= 0;
                        csr <= 0;
                        int_rst <= 0;
                    end
                    else begin
                        illegal_instr <= 1;
                        mem_req <= 0;
                        gpr_we_a <= 0;
                        branch <= 0;                  
                        jal <= 0;
                        jarl <= `PC_INC;
                        int_rst <= 0;
                    end
                end
                
                `MISC_MEM_OPCODE: begin
                    illegal_instr <= 0;
                    mem_req <= 0;
                    gpr_we_a <= 0;
                    branch <= 0;                  
                    jal <= 0;
                    jarl <= `PC_INC;
                    csrop <= 0;
                    csr <= 0;
                    int_rst <= 0;
                end
                
                `OP_IMM_OPCODE: begin
                    if (fetched_instr_i[14:12]!=8) begin
                        ex_op_a_sel <= `OP_A_RS1;
                        ex_op_b_sel <= `OP_B_IMM_I;                   
                        mem_req <= 0;
                        mem_we <= 0; //No matter
                        mem_size <= 0; //No matter
                        gpr_we_a <= 1;
                        wb_src_sel <= `WB_EX_RESULT;
                        branch <= 0;                   
                        jal <= 0;
                        jarl <= `PC_INC;   
                        csrop <= 0;
                        csr <= 0;      
                        int_rst <= 0;        
                        case (fetched_instr_i[14:12])
                            3'd0: begin
                                alu_op = `ALU_ADD;
                                illegal_instr <= 0;
                            end
                            3'd1: begin
                                alu_op = `ALU_SLL;
                                if (fetched_instr_i[31:25]==0)
                                    illegal_instr <= 0;
                                else begin
                                    illegal_instr <= 1;
                                    mem_req <= 0;
                                    gpr_we_a <= 0;
                                    branch <= 0;                  
                                    jal <= 0;
                                    jarl <= `PC_INC;
                                end
    
                            end
                            3'd2: begin
                                alu_op <= `ALU_SLTS;
                                illegal_instr <= 0;
                            end
                            3'd3: begin
                                alu_op <= `ALU_SLTU;
                                illegal_instr <= 0;
                            end
                            3'd4: begin
                                alu_op <= `ALU_XOR;
                                illegal_instr <= 0;
                            end
                            3'd5: begin
                                if (fetched_instr_i[31:25]==0) begin
                                    alu_op <= `ALU_SRL;
                                    illegal_instr <= 0;
                                end
                                else
                                    if (fetched_instr_i[31:25]==7'h20) begin
                                        alu_op <= `ALU_SRA;
                                        illegal_instr <= 0;
                                    end
                                    else begin
                                        illegal_instr <= 1;
                                        mem_req <= 0;
                                        gpr_we_a <= 0;
                                        branch <= 0;                  
                                        jal <= 0;
                                        jarl <= `PC_INC;
                                    end
    
                            end
                            3'd6: begin
                                alu_op <= `ALU_OR;
                                illegal_instr <= 0;
                            end
                            3'd7: begin
                                alu_op <= `ALU_AND;
                                illegal_instr <= 0;
                            end
                            default: begin
                                illegal_instr <= 1;
                                mem_req <= 0;
                                gpr_we_a <= 0;
                                branch <= 0;                  
                                jal <= 0;
                                jarl <= `PC_INC;
                            end
                        endcase                    
                    end
                end
                
                `AUIPC_OPCODE: begin
                    ex_op_a_sel <= `OP_A_CURR_PC;
                    ex_op_b_sel <= `OP_B_IMM_U;
                    alu_op <= `ALU_ADD;
                    mem_req <= 0;
                    mem_we <= 0; //No matter
                    mem_size <= 0; //No matter
                    gpr_we_a <= 1;
                    wb_src_sel <= `WB_EX_RESULT;
                    illegal_instr <= 0;
                    branch <= 0;
                    jal <= 0;
                    jarl <= `PC_INC;
                    csrop <= 0;
                    csr <= 0;
                    int_rst <= 0;
                end
                
                `STORE_OPCODE: begin
                    if (fetched_instr_i[14:12]<=2) begin
                        ex_op_a_sel <= `OP_A_RS1;
                        ex_op_b_sel <= `OP_B_IMM_S;
                        alu_op <= `ALU_ADD;
                        mem_req <= 1;
                        mem_we <= 1;
                        mem_size <= fetched_instr_i[14:12];
                        gpr_we_a <= 0;
                        wb_src_sel <= `WB_LSU_DATA; //No matter
                        illegal_instr <= 0;
                        branch <= 0;
                        jal <= 0;
                        jarl <= `PC_INC;
                        csrop <= 0;
                        csr <= 0;
                        int_rst <= 0;
                    end
                    else begin
                        illegal_instr <= 1;
                        mem_req <= 0;
                        gpr_we_a <= 0;
                        branch <= 0;                  
                        jal <= 0;
                        jarl <= `PC_INC;
                        csrop <= 0;
                        csr <= 0;
                        int_rst <= 0;
                    end
    
                end
                
                `OP_OPCODE: begin
                    ex_op_a_sel <= `OP_A_RS1;
                    ex_op_b_sel <= `OP_B_RS2;                   
                    mem_req <= 0;
                    mem_we <= 0; //No matter
                    mem_size <= 0; //No matter
                    gpr_we_a <= 1;
                    wb_src_sel <= `WB_EX_RESULT;
                    branch <= 0;                   
                    jal <= 0;
                    jarl <= `PC_INC;
                    csrop <= 0;  
                    csr <= 0;
                    int_rst <= 0;  
                    if (fetched_instr_i[31:25]==0)
                        case (fetched_instr_i[14:12])
                            3'd0: begin
                                alu_op <= `ALU_ADD;
                                illegal_instr <= 0;
                            end
                            3'd1: begin
                                alu_op <= `ALU_SLL;
                                illegal_instr <= 0;
                            end
                            3'd2: begin
                               alu_op <= `ALU_SLTS;
                               illegal_instr <= 0;
                            end
                            3'd3: begin
                                alu_op <= `ALU_SLTU;
                                illegal_instr <= 0;
                            end
                            3'd4: begin
                                alu_op <= `ALU_XOR;
                                illegal_instr <= 0;
                            end
                            3'd5: begin
                            alu_op <= `ALU_SRL;
                                illegal_instr <= 0;
                            end
                            3'd6: begin
                                alu_op <= `ALU_OR;
                                illegal_instr <= 0;
                            end
                            3'd7: begin
                                alu_op <= `ALU_AND;
                                illegal_instr <= 0;
                            end
                            default: begin
                                illegal_instr <= 1;
                                mem_req <= 0;
                                gpr_we_a <= 0;
                                branch <= 0;                  
                                jal <= 0;
                                jarl <= `PC_INC;
                            end
                        endcase
                    else
                        if (fetched_instr_i[31:25]==7'h20)
                            case (fetched_instr_i[14:12])
                                3'd0: begin
                                    alu_op <= `ALU_SUB;
                                    illegal_instr <= 0;
                                end
                                3'd5: begin
                                    alu_op <= `ALU_SRA;
                                    illegal_instr <= 0;
                                end
                                default: begin
                                    illegal_instr <= 1;
                                    mem_req <= 0;
                                    gpr_we_a <= 0;
                                    branch <= 0;                  
                                    jal <= 0;
                                    jarl <= `PC_INC;
                                end 
                            endcase
                        else
                            illegal_instr <= 1;
                end
                `LUI_OPCODE: begin
                    ex_op_a_sel <= `OP_A_ZERO;
                    ex_op_b_sel <= `OP_B_IMM_U; 
                    alu_op <= `ALU_ADD;                  
                    mem_req <= 0;
                    mem_we <= 0; //No matter
                    mem_size <= 0; //No matter
                    gpr_we_a <= 1;
                    wb_src_sel <= `WB_EX_RESULT; 
                    illegal_instr <= 0;
                    branch <= 0;                  
                    jal <= 0;
                    jarl <= `PC_INC;
                    csrop <= 0;
                    csr <= 0;
                    int_rst <= 0;
                end
                
                `BRANCH_OPCODE: begin
                    ex_op_a_sel <= `OP_A_RS1;
                    ex_op_b_sel <= `OP_B_RS2;                   
                    mem_req <= 0;
                    mem_we <= 0; //No matter
                    mem_size <= 0; //No matter
                    gpr_we_a <= 0;
                    wb_src_sel <= `WB_EX_RESULT; //No matter
                    branch <= 1;                   
                    jal <= 0;
                    jarl <= `PC_INC;
                    csrop <= 0;
                    csr <= 0;
                    int_rst <= 0;
                    case (fetched_instr_i[14:12])
                        3'd0: begin
                            alu_op <= `ALU_EQ;
                            illegal_instr <= 0;
                        end
                        3'd1: begin
                            alu_op <= `ALU_NE;
                            illegal_instr <= 0;
                        end
                        3'd4: begin
                            alu_op <= `ALU_LTS;
                            illegal_instr <= 0;
                        end
                        3'd5: begin
                            alu_op <= `ALU_GES;
                            illegal_instr <= 0;
                        end
                        3'd6: begin
                            alu_op <= `ALU_LTU;
                            illegal_instr <= 0;
                        end
                        3'd7: begin
                            alu_op <= `ALU_GEU;
                            illegal_instr <= 0;
                        end
                        default: begin
                            illegal_instr <= 1;
                            mem_req <= 0;
                            gpr_we_a <= 0;
                            branch <= 0;                  
                            jal <= 0;
                            jarl <= `PC_INC;
                        end
                    endcase
                    
                end
                
                `JALR_OPCODE: begin
                        if (fetched_instr_i[14:12]==0) begin
                            ex_op_a_sel <= `OP_A_CURR_PC;
                            ex_op_b_sel <= `OP_B_INCR; 
                            alu_op <= `ALU_ADD;                  
                            mem_req <= 0;
                            mem_we <= 0; //No matter
                            mem_size <= 0; //No matter
                            gpr_we_a <= 1;
                            wb_src_sel <= `WB_EX_RESULT; 
                            illegal_instr <= 0;
                            branch <= 0;                  
                            jal <= 0;
                            jarl <= `PC_JALR;
                            csrop <= 0;
                            csr <= 0;
                            int_rst <= 0;
                        end
                        else begin
                            illegal_instr <= 1;
                            mem_req <= 0;
                            gpr_we_a <= 0;
                            branch <= 0;                  
                            jal <= 0;
                            jarl <= `PC_INC;
                            csrop <= 0;
                            csr <= 0;
                            int_rst <= 0;
                        end
                    
                end
                
                `JAL_OPCODE: begin
                    ex_op_a_sel <= `OP_A_CURR_PC;
                    ex_op_b_sel <= `OP_B_INCR; 
                    alu_op <= `ALU_ADD;                  
                    mem_req <= 0;
                    mem_we <= 0; //No matter
                    mem_size <= 0; //No matter
                    gpr_we_a <= 1;
                    wb_src_sel <= `WB_EX_RESULT; 
                    illegal_instr <= 0;
                    branch <= 0;                  
                    jal <= 1;
                    jarl <= `PC_INC;
                    csrop <= 0;
                    csr <= 0;
                    int_rst <= 0;
                end
                `SYSTEM_OPCODE: begin
                    case (fetched_instr_i[14:12])
                        3'b000: begin
                            int_rst <= 1;
                            csr <= 0;
                            csrop <= 0;
                            illegal_instr <= 0;
                            gpr_we_a <= 0;
                            jarl <= `PC_MEPC;
                        end
                        3'b001: begin
                            csr <= 1;
                            csrop <= 1;
                            int_rst <= 0;
                            illegal_instr <= 0;
                            gpr_we_a <= 1;
                            jarl <= `PC_INC;
                        end
                        3'b010: begin
                            csr <= 1;
                            csrop <= 2;
                            int_rst <= 0;
                            illegal_instr <= 0;
                            gpr_we_a <= 1;
                            jarl <= `PC_INC;                            
                        end
                        3'b011: begin
                            csr <= 1;
                            csrop <= 3;
                            int_rst <= 0;
                            illegal_instr <= 0;
                            gpr_we_a <= 1;
                            jarl <= `PC_INC;                            
                        end
                        default: begin
                            illegal_instr <= 1;
                            mem_req <= 0;
                            gpr_we_a <= 0;
                            branch <= 0;                  
                            jal <= 0;
                            jarl <= `PC_INC;
                            csrop <= 0;
                            csr <= 0;
                            int_rst <= 0;
                        end
                    endcase
                    mem_req <= 0;
                    branch <= 0;                  
                    jal <= 0;
                    
                end 
                default: begin
                    illegal_instr <= 1;
                    mem_req <= 0;
                    gpr_we_a <= 0;
                    branch <= 0;                  
                    jal <= 0;
                    jarl <= `PC_INC;
                    csrop <= 0;
                    csr <= 0;
                    int_rst <= 0;
                end          
            endcase
        end
        else begin
            illegal_instr <= 1;
            mem_req <= 0;
            gpr_we_a <= 0;
            branch <= 0;                  
            jal <= 0;
            jarl <= `PC_INC;
            csrop <= 0;
            csr <= 0;
            int_rst <= 0;
        end
    end
    //Interrupt (INT)
    else begin
        illegal_instr <= 0;
        mem_req <= 0;
        gpr_we_a <= 0;
        branch <= 0;                  
        jal <= 0;
        jarl <= `PC_MTVEC;        
        csrop <= 3'b100;
        csr <= 0;
        
    end
end
endmodule