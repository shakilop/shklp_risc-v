module miriscv(
    input clk_i,
    input rst,
    input [15:0] sw_i,
	output [31:0] HEX 	
);



reg [31:0]   PC = 0;
reg [31:0]  register_file_WD3; 



wire [31:0] instruction;
wire [31:0] register_file_parametr_rd1;
wire [31:0] register_file_parametr_rd2;
wire [31:0] alu_result;
wire        alu_flag;




assign HEX = register_file_parametr_rd1;
							
							

miriscv_instruction_memory instructions (.clk(clk_i),.adr(PC),.rd(instruction));

miriscv_register_file register_file_inst (.clk(clk_i),
                       .rst(rst),
                       .write_enable(instruction[29]),
                       .parametr_adress_a1(instruction[22:18]),
                       .parametr_adress_a2(instruction[17:13]),
                       .parametr_adress_a3(instruction[12:8]),
                       .input_data(register_file_WD3),
                       .parametr_a1(register_file_parametr_rd1),
                       .parametr_a2(register_file_parametr_rd2));
							  
miriscv_alu alu_inst (.operator_i(instruction[26:23]),
                      .operand_a_i(register_file_parametr_rd1),
                      .operand_b_i(register_file_parametr_rd2),
                      .result_o(alu_result),
                      .comparison_result_o(alu_flag));

always @(*) begin
    case (instruction[28:27])
        2'd0: register_file_WD3 <= {{24{instruction[7]}},instruction[7:0]};
        2'd1: register_file_WD3 <= sw_i[15:0];
        2'd2: register_file_WD3 <= alu_result;
        default: register_file_WD3 <= 0;
    endcase
end      
                      
always @(posedge clk_i or posedge rst) begin
        if (rst)
            PC <= 0;
        else begin
            case ((alu_flag&instruction[30])|instruction[31])
                1'b0: PC <= PC + 1;
                1'b1: PC <= PC + {{24{instruction[7]}},instruction[7:0]};
            endcase
	    end
	    
end

 
                      
                      
endmodule