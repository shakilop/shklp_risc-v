module miriscv_tb ();

reg clk = 0;
reg rst = 0;
reg [15:0] SW = 0;
wire [31:0] HEX;

miriscv miriscv_tb_inst (.clk_i(clk),
                         .rst(rst),
                         .sw_i(SW),
                         .HEX(HEX));

always 
begin
    #5 clk = ~clk;
end

initial begin #5
    rst = 1; #202
    rst = 0;
    SW[15:0] = 16'b1001100000;
end

endmodule