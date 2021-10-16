module miriscv_register_file (
input clk,
input rst,
input write_enable,
input [4:0] parametr_adress_a1,
input [4:0] parametr_adress_a2,
input [4:0] parametr_adress_a3,
input [31:0] input_data,
output [31:0] parametr_a1,
output [31:0] parametr_a2
);

reg [31:0] register[30:0];
reg [4:0] i;

assign parametr_a1 = parametr_adress_a1 != 0 ? register[parametr_adress_a1-1] : 0;
assign parametr_a2 = parametr_adress_a2 != 0 ? register[parametr_adress_a2-1] : 0;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 31; i = i + 1)
            register[i] <= 0;
    end else
    if (write_enable) begin
        register[parametr_adress_a3-1] <= input_data;
    end
end

endmodule