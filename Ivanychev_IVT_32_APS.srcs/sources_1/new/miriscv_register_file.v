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

//reg [31:0] parametr_a1_reg;
//reg [31:0] parametr_a2_reg;

//assign parametr_a1 = parametr_a1_reg;
//assign parametr_a2 = parametr_a2_reg;

reg [31:0] register[31:0];
reg [5:0] i;

assign parametr_a1 = register[parametr_adress_a1];
assign parametr_a2 = register[parametr_adress_a2];

//always @* begin
//    if (parametr_adress_a1==0) begin
//        parametr_a1_reg <= 0;
//    end
//    else begin
//        parametr_a1_reg <= register[parametr_adress_a1];
//    end
    
//    if (parametr_adress_a2==0) begin
//        parametr_a2_reg <= 0;
//    end
//    else begin
//        parametr_a2_reg <= register[parametr_adress_a2];
//    end
//end

//Write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 32; i = i + 1)
            register[i] <= 0;
    end else
    if (write_enable) begin
        if (parametr_adress_a3 != 0) begin
            register[parametr_adress_a3] <= input_data;
        end       
    end
end

endmodule