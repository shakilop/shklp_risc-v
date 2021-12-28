module miriscv_csr(
    input           clk_i,
    input [11:0]    A_i,
    input [31:0]    WD_i,
    input [2:0]     OP_i,
    input [31:0]    mcause_i,
    input [31:0]    PC_i,
    output [31:0]   mie_o,
    output [31:0]   mtvec_o,
    output [31:0]   mepc_o,
    output [31:0]   RD_o
);

reg [31:0] mie = 0;
reg [31:0] mtvec;
reg [31:0] mepc;
reg [31:0] RD;
reg [31:0] mscratch; //0x340
reg [31:0] mcause;   //0x342
reg [31:0] buff;


assign mie_o = mie;
assign mtvec_o = mtvec;
assign mepc_o = mepc;
assign RD_o = RD;

always @(*) begin
    case (A_i)
        12'h304: RD <= mie;
        12'h305: RD <= mtvec;
        12'h340: RD <= mscratch;
        12'h341: RD <= mepc;
        12'h342: RD <= mcause;
    endcase


end

always @(*) begin
    //!!!!!!!!ÂÎÇÌÎÆÍÀ ÎØÈÁÊÀ(ÏÐÎ ÄÎÂÅÐÈÅ Ê ÌÅÒÎÄÈ×ÊÅ è âîçìîæíî ïîñïåøíûå èñïðàâëåíèÿ)!!!!!!!!!
    case (OP_i[1:0])
        2'd2: begin
            buff <= RD | WD_i;
        end 
        2'd3: begin
            buff <= RD & (~WD_i);   
        end
        3'd1: begin
            buff <= WD_i;
        end
        3'd0: begin
            buff <= 32'd0;
        end
    endcase
end



always @(posedge clk_i) begin
    if (OP_i[2]) begin
        mepc <= PC_i;
        mcause <= mcause_i;
    end
    case (A_i)
        12'h304: begin
            if (OP_i[1]|OP_i[0])
                mie <= buff;
        end
        12'h305: begin
            if (OP_i[1]|OP_i[0])
                mtvec <= buff;
        end
        12'h340: begin
            if (OP_i[1]|OP_i[0])
                mscratch <= buff;
        end
        12'h341: begin
            if (OP_i) begin
                case (OP_i[2])
                    1'b1: mepc <= PC_i;
                    1'b0: mepc <= buff;
                endcase
            end
        end
        12'h342: begin
            if (OP_i[2:0]) begin
                case (OP_i[2])
                    1'b1: mcause <= mcause_i;
                    1'b0: mcause <= buff;
                endcase
            end
        end
    endcase
end

endmodule



