`timescale 1ns / 1ps

//`define ALU_ADD 6'b011000
//`define ALU_SUB 6'b011001
//`define ALU_XOR 6'b101111
//`define ALU_OR  6'b101110
//`define ALU_AND 6'b010101
//`define ALU_SRA 6'b100100
//`define ALU_SRL 6'b100101
//`define ALU_SLL 6'b100111
//`define ALU_LTS 6'b000000
//`define ALU_LTU 6'b000001
//`define ALU_GES 6'b001010
//`define ALU_GEU 6'b001011
//`define ALU_EQ  6'b001100
//`define ALU_NE  6'b001101

`define ALU_ADD 4'b0000
`define ALU_SUB 4'b0001
`define ALU_XOR 4'b0010
`define ALU_OR  4'b0011
`define ALU_AND 4'b0100
`define ALU_SRA 4'b0101
`define ALU_SRL 4'b0110
`define ALU_SLL 4'b0111
`define ALU_LTS 4'b1000
`define ALU_LTU 4'b1001
`define ALU_GES 4'b1010
`define ALU_GEU 4'b1011
`define ALU_EQ  4'b1100
`define ALU_NE  4'b1101

module tb_alu();

reg  [5:0]  operator;
reg  [31:0] operand_a;
reg  [31:0] operand_b;
wire [31:0] result;
wire        comparison_result;

reg [9:0] counter;
integer fd;

miriscv_alu miriscv_alu_inst(.operator_i(operator),
             .operand_a_i(operand_a),
             .operand_b_i(operand_b),
             .result_o(result),
             .comparison_result_o(comparison_result));

function [23:0] char_of_operation (input [5:0] operator_f);
    begin
        char_of_operation = 0;
        case (operator_f)
            `ALU_ADD: char_of_operation = "+";
            `ALU_SUB: char_of_operation = "-";
            `ALU_XOR: char_of_operation = "^";
            `ALU_OR:  char_of_operation = "|";
            `ALU_AND: char_of_operation = "&";
            `ALU_SRA: char_of_operation = ">>>";
            `ALU_SRL: char_of_operation = ">>";
            `ALU_SLL: char_of_operation = "<<";
            `ALU_LTS,
            `ALU_LTU: char_of_operation = "<";
            `ALU_GES,
            `ALU_GEU: char_of_operation = ">=";
            `ALU_EQ:  char_of_operation = "==";
            `ALU_NE:  char_of_operation = "!=";
        endcase
    end
endfunction

task alu_oper_test;
    input integer operand_a_tb;
    input integer operand_b_tb;
    input integer result_tb;
    input comparison_result_tb;

    begin    
        operand_a = operand_a_tb;
        operand_b = operand_b_tb;
        #10
        if (result === result_tb && comparison_result === comparison_result_tb) begin
                $display("Test %d PASS in %m", counter);
                $display("Time = ",$realtime);
                $fdisplay (fd,"Test %d PASS:       %b %s %b == %b and comparison_result = %b", counter, operand_a, char_of_operation(operator), operand_b, result, comparison_result_tb);
            end
            else begin 
                 $display(
                 "Test %d FAILED in %m \noperand_a_tb: %b\noperand_b_tb: %b\nresult_tb: %b\nresult:    %b\ncomparison_result_tb: %b\ncomparison_result: %b",
                 counter , operand_a_tb, operand_b_tb, result_tb, result, comparison_result_tb, comparison_result);
                 $fdisplay(fd,"Test %d NOT PASSED: %b %s %b != %b or  comparison_result != %b", counter, operand_a_tb, char_of_operation(operator), operand_b_tb, result_tb, comparison_result_tb);
           
            end
        counter = counter + 1;    
    end
endtask


initial begin
    counter = 10'd0;
    fd = $fopen("alu_tb_log.txt","a+");
   //ADD
    $display("Add Test's"); //0-7
    operator = `ALU_ADD;
    alu_oper_test (32'd0,32'd0,32'd0,0);
    alu_oper_test (32'd1,32'd0,32'd1,0);
    alu_oper_test (32'hFFFFFFFF,32'd0,32'hFFFFFFFF,0);
    alu_oper_test (32'hFFFFFFFF,32'd1,32'd0,0);
    alu_oper_test (32'd250,32'd260,32'd510,0);
    alu_oper_test (32'd2_123_678_934,32'd123_678_934,32'd2_247_357_868,0);
    alu_oper_test (32'd8_134_484,32'd8_034_680,32'd16_169_164,0);
    alu_oper_test (32'd123_456,32'd65_432,32'd188_888,0);
    
    $display ("\nSub Test's"); //8-15
    operator = `ALU_SUB;
    alu_oper_test (32'd0,32'd0,32'd0,0);
    alu_oper_test (32'd0,32'd1,32'hFFFFFFFF,0);
    alu_oper_test (32'hFFFFFFFF,32'hEEEEEEEE,32'h11111111,0);
    alu_oper_test (32'hFFFFFFFF,32'hFFFFFFFF,32'h0,0);
    alu_oper_test (32'd123_456,32'd65_432,32'd58_024,0);
    alu_oper_test (32'd2_123_678_934,32'd123_678_934,32'd2_000_000_000,0);
    alu_oper_test (32'd32_225_848,32'd18_200_781,32'd14_025_067,0);
    alu_oper_test (32'd8_134_484,32'd8_034_680,32'd99_804,0);
    
    $display ("\nXor Test's"); //16-23
    operator = `ALU_XOR;
    alu_oper_test (32'd0,32'd0,32'd0,0);
    alu_oper_test (32'd0,32'd1,32'd1,0);
    alu_oper_test (32'd8,32'd1,32'd9,0);
    alu_oper_test (32'b11010100,32'b10100010,32'b01110110,0);
    alu_oper_test (32'hFFFFFFFF,32'hEEEEEEEE,32'h11111111,0);
    alu_oper_test (32'b00110101_11111111_10010101_00101101,
                   32'b10010101_11111111_01101010_10100101,
                   32'b10100000_00000000_11111111_10001000,0);
    alu_oper_test (32'b10010101_01010101_10100101_10100101,
                   32'b11010101_01100101_11101010_00010101,
                   32'b01000000_00110000_01001111_10110000,0);
    alu_oper_test (32'hAC_BD_EF_01,32'h4B_A7_C9_DF,32'hE7_1A_26_DE,0);
    
    
    $display ("\nOr Test's"); //24-31
    operator = `ALU_OR;
    
    alu_oper_test (32'd0,32'd0,32'd0,0);
    alu_oper_test (32'd0,32'd1,32'd1,0);
    alu_oper_test (32'd8,32'd1,32'd9,0);
    alu_oper_test (32'b11010100,32'b10100010,32'b11110110,0);
    alu_oper_test (32'hFFFFFFFF,32'hEEEEEEEE,32'hFFFFFFFF,0);
    alu_oper_test (32'b00110101_11111111_10010101_00101101,
                   32'b10010101_11111111_01101010_10100101,
                   32'b10110101_11111111_11111111_10101101,0);
    alu_oper_test (32'b10010101_01010101_10100101_10100101,
                   32'b11010101_01100101_11101010_00010101,
                   32'b11010101_01110101_11101111_10110101,0);
    alu_oper_test (32'hAC_BD_EF_01,32'h4B_A7_C9_DF,32'hEF_BF_EF_DF,0);
    
    $display ("\nAnd Test's"); //32-39
    operator = `ALU_AND;
    alu_oper_test (32'd0,32'd0,32'd0,0);
    alu_oper_test (32'd0,32'd1,32'd0,0);
    alu_oper_test (32'd8,32'd8,32'd8,0);
    alu_oper_test (32'b11010100,32'b10100010,32'b10000000,0);
    alu_oper_test (32'hFFFFFFFF,32'hEEEEEEEE,32'hEEEEEEEE,0);
    alu_oper_test (32'b00110101_11111111_10010101_00101101,
                   32'b10010101_11111111_01101010_10100101,
                   32'b00010101_11111111_00000000_00100101,0);
    alu_oper_test (32'b10010101_01010101_10100101_10100101,
                   32'b11010101_01100101_11101010_00010101,
                   32'b10010101_01000101_10100000_00000101,0);
    alu_oper_test (32'hAC_BD_EF_01,32'h4B_A7_C9_DF,32'h08_A5_C9_01,0);
    
    $display ("\nSRA Test's"); //40-47
    operator = `ALU_SRA;
    
    alu_oper_test (32'd0,32'd0,32'd0,0);
    alu_oper_test (32'd0,32'd1,32'd0,0);
    alu_oper_test (32'd8,32'd3,32'd1,0);
    alu_oper_test (32'h80_00_00_AA,32'd3,32'hF0_00_00_15,0);
    alu_oper_test (32'h80_00_00_00,32'd32,32'hFF_FF_FF_FF,0);
    alu_oper_test (32'h00_FF_00_00,32'd8,32'h00_00_FF_00,0);
    alu_oper_test (32'h80_FF_00_00,32'd8,32'hFF_80_FF_00,0);
    alu_oper_test (32'h7F_FF_FF_FF,32'd32,32'h0,0);

    $display ("\nSRL Test's"); //48-55
    operator = `ALU_SRL;
    alu_oper_test (32'd0,32'd0,32'd0,0);
    alu_oper_test (32'd0,32'd1,32'd0,0);
    alu_oper_test (32'd8,32'd3,32'd1,0);
    alu_oper_test (32'h80_00_00_AA,32'd3,32'h10_00_00_15,0);
    alu_oper_test (32'h80_00_00_00,32'd31,32'h1,0);
    alu_oper_test (32'h00_FF_00_00,32'd8,32'h00_00_FF_00,0);
    alu_oper_test (32'h80_FF_00_00,32'd8,32'h00_80_FF_00,0);
    alu_oper_test (32'hFF_FF_FF_FF,32'd32,32'h0,0);

    $display ("\nSLL Test's"); //56-63
    operator = `ALU_SLL;
    alu_oper_test (32'd0,32'd0,32'd0,0);
    alu_oper_test (32'd0,32'd1,32'd0,0);
    alu_oper_test (32'd8,32'd3,32'd64,0);
    alu_oper_test (32'h80_00_00_AA,32'd3,32'h00_00_05_50,0);
    alu_oper_test (32'h00_00_00_01,32'd31,32'h80_00_00_00,0);
    alu_oper_test (32'h00_FF_00_00,32'd8,32'hFF_00_00_00,0);
    alu_oper_test (32'h80_80_FF_00,32'd8,32'h80_FF_00_00,0);
    alu_oper_test (32'hFF_FF_FF_FF,32'd32,32'h0,0);
    
    $display ("\nLTS Test's"); //64-71
    operator = `ALU_LTS;
    
    alu_oper_test (32'd0,32'd0,32'd0,0);
    alu_oper_test (32'd0,32'd1,32'd1,1);
    alu_oper_test (32'h00_00_FE_00,32'h00_00_FF_00,1,1);
    alu_oper_test (32'h80_00_FE_00,32'h80_00_FF_00,1,1);
    alu_oper_test (32'h80_FF_00_00,32'h80_FE_00_00,0,0);
    alu_oper_test (32'hFF_FF_FF_FF,32'h00_00_00_01,1,1);
    alu_oper_test (32'h00_AE_00_00,32'h00_AE_00_00,0,0);
    alu_oper_test (32'h00_FF_00_00,32'h00_FE_00_00,0,0);
    
    $display ("\nLTU Test's"); //72-79
    operator = `ALU_LTU;
    
    alu_oper_test (32'd0,32'd0,32'd0,0);
    alu_oper_test (32'd0,32'd1,32'd1,1);
    alu_oper_test (32'h00_00_FE_00,32'h00_00_FF_00,1,1);
    alu_oper_test (32'h80_00_FE_00,32'h80_00_FF_00,1,1);
    alu_oper_test (32'h80_FF_00_00,32'h80_FE_00_00,0,0);
    alu_oper_test (32'hFF_FF_FF_FF,32'h00_00_00_01,0,0);
    alu_oper_test (32'h00_AE_00_00,32'h00_AE_00_00,0,0);
    alu_oper_test (32'h00_FF_00_00,32'h00_FE_00_00,0,0);
    
    $display ("\nGES Test's"); //80-87
    operator = `ALU_GES;
    alu_oper_test (32'd0,32'd0,32'd1,1);
    alu_oper_test (32'd0,32'd1,32'd0,0);
    alu_oper_test (32'h00_00_FE_00,32'h00_00_FF_00,0,0);
    alu_oper_test (32'h80_00_FE_00,32'h80_00_FF_00,0,0);
    alu_oper_test (32'h80_FF_00_00,32'h80_FE_00_00,1,1);
    alu_oper_test (32'hFF_FF_FF_FF,32'h00_00_00_01,0,0);
    alu_oper_test (32'h00_AE_00_00,32'h00_AE_00_00,1,1);
    alu_oper_test (32'h00_FF_00_00,32'h00_FE_00_00,1,1);
    
    $display ("\nGEU Test's"); //88-95
    operator = `ALU_GEU;
    
    alu_oper_test (32'd0,32'd0,32'd1,1);
    alu_oper_test (32'd0,32'd1,32'd0,0);
    alu_oper_test (32'h00_00_FE_00,32'h00_00_FF_00,0,0);
    alu_oper_test (32'h80_00_FE_00,32'h80_00_FF_00,0,0);
    alu_oper_test (32'h80_FF_00_00,32'h80_FE_00_00,1,1);
    alu_oper_test (32'hFF_FF_FF_FF,32'h00_00_00_01,1,1);
    alu_oper_test (32'h00_AE_00_00,32'h00_AE_00_00,1,1);
    alu_oper_test (32'h00_FF_00_00,32'h00_FE_00_00,1,1);
    
    $display ("\nEQ Test's");
    operator = `ALU_EQ;
    
    alu_oper_test (32'd0,32'd0,32'd1,1);
    alu_oper_test (32'd0,32'd1,32'd0,0);
    alu_oper_test (32'h00_00_FE_00,32'h00_00_FF_00,0,0);
    alu_oper_test (32'h80_00_FE_00,32'h80_00_FF_00,0,0);
    alu_oper_test (32'h80_FF_00_00,32'h80_FE_00_00,0,0);
    alu_oper_test (32'hFF_FF_FF_FF,32'h00_00_00_01,0,0);
    alu_oper_test (32'h00_AE_00_00,32'h00_AE_00_00,1,1);
    alu_oper_test (32'h00_FF_00_00,32'h00_FE_00_00,0,0);    
    
    $display ("\nNE Test's");
    
    alu_oper_test (32'd0,32'd0,32'd0,0);
    alu_oper_test (32'd0,32'd1,32'd1,1);
    alu_oper_test (32'h00_00_FE_00,32'h00_00_FF_00,1,1);
    alu_oper_test (32'h80_00_FE_00,32'h80_00_FF_00,1,1);
    alu_oper_test (32'h80_FF_00_00,32'h80_FE_00_00,1,1);
    alu_oper_test (32'hFF_FF_FF_FF,32'h00_00_00_01,1,1);
    alu_oper_test (32'h00_AE_00_00,32'h00_AE_00_00,0,0);
    alu_oper_test (32'h00_FF_00_00,32'h00_FE_00_00,1,1);
    
         
    $fclose(fd);
    $finish;
end

endmodule



























