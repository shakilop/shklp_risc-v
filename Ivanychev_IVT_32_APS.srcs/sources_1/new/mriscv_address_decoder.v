module miriscv_address_decoder (
    input [31:0]    addr_i,
    input           we_i,
    input           req_i,
    
    output [1:0] RDsel_o,
    
    //Memory
    output we_mem_o,
    output req_mem_o,
    
    //Keyboard
    output we_d0_o,
    
    //LEDs
    output we_d1_o
    
 );



reg [1:0] RDsel;
assign RDsel_o = RDsel;

//Memory signals
assign we_mem_o = we_i & ({addr_i[31:10],10'b0}==32'h00000000);
assign req_mem_o = req_i & ({addr_i[31:10],10'b0}==32'h00000000);

//KeyBoard signals
assign we_d0_o = we_i & req_i & (addr_i[31:0]==32'h80003000);

//LEDs signals
assign we_d1_o = we_i & req_i & ({addr_i[31:4],4'b0}==32'h80001000);

always @(*) begin
    
    case (addr_i[31:12])
        //Memory
        20'h0: begin
            RDsel <= 0;
        end
        //Keyboard
        20'h80003: begin
            RDsel <= 1;
        end
        //LED_display
        20'h80001: begin
            RDsel <= 2;
        end
        default: begin
            //Что писать?
        end
    endcase        
end

endmodule