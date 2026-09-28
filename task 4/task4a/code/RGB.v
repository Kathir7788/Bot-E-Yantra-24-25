module rgb(
	input clK_1MHZ,done,
	input [1:0] filter,color,
	output reg blue1,blue2,blue3,blue4,red1,red2,red3,red4,green1,green2,green3,green4,s0,s1,OE,
	output s2,s3
);

reg [20:0] count;
reg en_red,en_green,en_blue;

initial begin
	s0 = 1; s1 = 1; OE = 0; count = 0; en_red = 1; en_green = 1; en_blue = 1;
end

always @(posedge clK_1MHZ)begin
   if (done) begin
		 if (count < 1000000) begin
			  green1 = 1; green2 = 1; green3 = 1; green4 = 1;
			  red1   = 0; red2   = 0; red3   = 0; red4   = 0;
			  blue1  = 0; blue2  = 0; blue3  = 0; blue4  = 0;
			  count <= count + 1;
		 end else if (count < 2000000) begin
			  green1 = 0; green2 = 0; green3 = 0; green4 = 0;
			  red1   = 0; red2   = 0; red3   = 0; red4   = 0;
			  blue1  = 0; blue2  = 0; blue3  = 0; blue4  = 0;
			  count <= count + 1;
		 end else begin
			  count <= 0;
		 end
	end else begin
		case(color)
			2'b0:begin
				red1 = 0; green1 = 0; blue1 = 0;
				en_red = 1; en_green = 1; en_blue = 1;
			end
			2'b1:begin
				if(en_red)begin
					red1 = 1; green1 = 0; blue1 = 0; 
					en_red = 0; en_green = 1; en_blue = 1;
				end
			end
			2'b10:begin
				if(en_green)begin
					red1 = 0; green1 = 1; blue1 = 0; 
					en_red = 1; en_green = 0; en_blue = 1;
				end
			end
			2'b11:begin
				if(en_blue)begin
					red1 = 0; green1 = 0; blue1 = 1; 
					en_red = 1; en_green = 1; en_blue = 0;
				end
			end
		endcase
	end
end

assign {s2,s3} = filter; 
endmodule 