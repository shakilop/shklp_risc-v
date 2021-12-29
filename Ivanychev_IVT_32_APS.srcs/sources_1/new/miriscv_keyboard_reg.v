//`timescale 1ns / 1ps

module miriscv_keyboard_reg(
    input           clk_i,
    input           rstn_i,
    //from keyboard
    input           valid_data_i,
    input [7:0]     data_i,
    //to cpu
    input           int_fin_i,
    output          int_req_o,
    output [31:0]   data_o
);


reg         flag_F0;
reg [7:0]   data;
reg         int_req;

wire int_fin = int_fin_i;

assign data_o = data;
assign int_req_o = int_req;

always @(posedge int_fin_i) begin
    int_req <= 0;
end

always @(posedge valid_data_i) begin
    //Кнопка нажата
    if (!flag_F0) begin
       
        if (data_i != 8'hF0)
            //Нет кнопки в обработке
            if (!int_req) begin
                data <= data_i;
                int_req <= 1;
            end
        else
            flag_F0 <= 1;
    end
    else begin
        flag_F0 <= 0;
    end
end

always @(posedge rstn_i) begin
    flag_F0 <= 0;
    data <= 0;
    int_req <= 0;
end


endmodule










