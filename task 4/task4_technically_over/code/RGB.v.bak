module rgb(
	input [1:0] filter,color,
	output reg blue,red,green,s0,s1,OE,
	output s2,s3
);

initial begin
	s0 = 1; s1 = 1; OE = 0;
end

always @(*) begin
	case(color)
		2'b0:begin
			red = 0; green = 0; blue = 0;
		end
		2'b1:begin
			red = 1; green = 0; blue = 0; 
		end
		2'b10:begin
			red = 0; green = 1; blue = 0; 
		end
		2'b11:begin
			red = 0; green = 0; blue = 1; 
		end
	endcase
end

assign {s2,s3} = filter; 
endmodule 