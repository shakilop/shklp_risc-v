module dec_BIN_to_HEX (
	input [3:0] bin,
	output reg [6:0] hex);

	always @* begin
		case (bin)
			4'd0: 	hex <= 7'b100_0000;
			4'd1: 	hex <= 7'b111_1001;
			4'd2: 	hex <= 7'b010_0100;
			4'd3: 	hex <= 7'b011_0000;
			4'd4: 	hex <= 7'b001_1001;
			4'd5: 	hex <= 7'b001_0010;
			4'd6: 	hex <= 7'b000_0010;
			4'd7: 	hex <= 7'b111_1000;
			4'd8: 	hex <= 7'b000_0000;
			4'd9: 	hex <= 7'b001_1000;
			default: hex <= 7'b000_1110;
		endcase
	end
	
endmodule