`include "miriscv_defines.v"

module miriscv_data_memory (
    input         clk_i,
    input [31:0]  address_i,
    input [31:0]  data_i,
    input         access_i,
    input         we_i,
    input [2:0]   wsize_i,
    output [31:0] data_o
);

reg [31:0] memory[31:0];

reg [31:0] data;
assign data_o = data;

always @(posedge clk_i) begin
    if (access_i) begin
        if (we_i) begin
        //Read
            case (wsize_i)
                `LDST_B: begin
                    case (address_i[1:0])
                        2'd0: memory[address_i >> 2] <= {memory[address_i>>2][31:8],data_i[7:0]};
                        2'd1: memory[address_i >> 2] <= {memory[address_i>>2][31:16],data_i[7:0],memory[address_i>>2][7:0]};
                        2'd2: memory[address_i >> 2] <= {memory[address_i>>2][31:24],data_i[7:0],memory[address_i>>2][15:0]};
                        2'd3: memory[address_i >> 2] <= {data_i[7:0],memory[address_i>>2][23:0]};
                    endcase
                end
                `LDST_H: begin
                    case (address_i[1])
                        1'd0: memory[address_i >> 2] <= {memory[address_i>>2][31:16],data_i[15:0]};
                        1'd1: memory[address_i >> 2] <= {data_i[15:0],memory[address_i>>2][15:0]};
                    endcase
                end
                `LDST_W:
                    memory[address_i >> 2] <= {data_i[31:0]};
            endcase
        end
        //Write
        else begin
            case (wsize_i)
                `LDST_B: begin
                    case (address_i[1:0])
                        2'd0: data = {{24{memory[address_i>>2][7]}},memory[address_i>>2][7:0]};
                        2'd1: data = {{24{memory[address_i>>2][15]}},memory[address_i>>2][15:8]};
                        2'd2: data = {{24{memory[address_i>>2][23]}},memory[address_i>>2][23:16]};
                        2'd3: data = {{24{memory[address_i>>2][31]}},memory[address_i>>2][31:24]};
                    endcase
                end
                `LDST_H: begin
                    case (address_i[1])
                        1'd0: data = {{16{memory[address_i>>2][15]}},memory[address_i>>2][15:0]};
                        1'd1: data = {{16{memory[address_i>>2][31]}},memory[address_i>>2][31:16]};
                    endcase
                end
                `LDST_W: begin
                    data = memory[address_i>>2];
                end
                `LDST_BU: begin
                    case (address_i[1:0])
                        2'd0: data = {{24{1'd0}},memory[address_i>>2][7:0]};
                        2'd1: data = {{24{1'd0}},memory[address_i>>2][15:8]};
                        2'd2: data = {{24{1'd0}},memory[address_i>>2][23:16]};
                        2'd3: data = {{24{1'd0}},memory[address_i>>2][31:24]};
                    endcase
                end
                `LDST_HU: begin
                    case (address_i[1])
                        1'd0: data = {{16{1'd0}},memory[address_i>>2][15:0]};
                        1'd1: data = {{16{1'd0}},memory[address_i>>2][31:16]};
                    endcase
                end
            endcase
        end
    end
end

endmodule