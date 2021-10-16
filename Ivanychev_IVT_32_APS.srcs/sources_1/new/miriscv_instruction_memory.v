module miriscv_instruction_memory (
    input clk,
    input [4:0] adr,
    output [31:0] rd    
);

reg [31:0] RAM [31:0];
initial $readmemb ("F:/Ivanychev_IVT_32_APS/program.txt", RAM);

assign rd = RAM[adr];



endmodule