//`timescale 1ns / 1ps


module LED_reg(
    input clk_i,
    input rstn_i,
    
    input [31:0] addr_i,
    input [31:0] data_i,
    input [3:0] be_i,
    input we_i,
    
    output [31:0] data_o
);
reg [31:0] mem [0:2];


assign data_o = mem[addr_i[3:2]];

always @(posedge clk_i or posedge rstn_i) begin    
    
    if (rstn_i) begin
        mem[0] <= 0;
        mem[1] <= 0;
        mem[2] <= 0;
    end
    else begin
        if(we_i && be_i[0])
        mem [addr_i[3:2]] [7:0]  <= data_i[7:0];
        
        if(we_i && be_i[1])
        mem [addr_i[3:2]] [15:8] <= data_i[15:8];
        
        if(we_i && be_i[2])
        mem [addr_i[3:2]] [23:16] <= data_i[23:16];
        
        if(we_i && be_i[3])
        mem [addr_i[3:2]] [31:24] <= data_i[31:24];
    end
end



endmodule
