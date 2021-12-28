module miriscv_interrupt_contr(
    input           clk_i,
    input           rst_i,
    input [31:0]    mie_i,
    input [31:0]    int_req_i,
    input           INT_RST_i, //Прерывание обработано
    output [31:0]   mcause_o,
    output [31:0]   int_fin_o,
    output          INT_o
);

wire       en;

reg [4:0]  counter;
reg        INT_reg;
reg [31:0] dec;

assign mcause_o = {27'h0000000,counter};
assign int_fin_o = (mie_i&int_req_i)&{31{INT_RST_i}}&dec;
assign en = ((mie_i & int_req_i) & dec)!=0 ? 1 : 0;
assign INT_o = (INT_reg || en)&&(!(INT_reg && en));

 
always @(*) begin
    if (INT_RST_i) begin
        INT_reg <= 0;
        counter <= 0;   
    end
end

always @(posedge clk_i) begin
    if (rst_i) begin
        counter <= 0;
        dec <= 1;
        INT_reg <= 0;
    end 
    else begin
        
        INT_reg <= en || en;  

        if (!en) begin            
            counter <= counter + 1;
            case (dec)
                32'h80000000: dec <= 1;
                default: dec <= dec << 1;
            endcase
            
        end
    end
end

endmodule