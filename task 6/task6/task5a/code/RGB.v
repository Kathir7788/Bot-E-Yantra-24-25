/*
# Team ID:          3699
# Theme:            EcoMender Bot
# Author List:      NISHANTH, HARIKARAN, ADITHIYA, KATHIR
# Filename:         rgb
# File Description: entire controls are done 
# Global variables: 
	clK_1MHZ: 1MHz clock signal
	done: tindicate end of the run
	filter: to detect RGB color
	color: final colour detected after sensing
	COLOR_STATE: turns high after done becomes one to indicate end run
	EI: Event INdicato
	pwm_signal: to glow yellow led
	reset_var: resets all variables to initial state
	blue1,blue2,blue3,blue_mi,red1,red2,red3,red_mi,green1,green2,green3,green_mi: respective colour and sub unit color led 
	s0,s1: color sensor sensitivity scaling
	s2,s3: filter selector
	en_yellow: to glow yellow led after receiving CSL msg
*/

module rgb(
	input clK_1MHZ,done,
	input [1:0] filter,color,
	input [2:0] COLOR_STATE,
	input [2:0] EI,
	input pwm_signal,reset_var,
	output reg blue1,blue2,blue3,blue_mi,red1,red2,red3,red_mi,green1,green2,green3,green_mi,s0,s1,OE,
	output s2,s3,
	output reg en_yellow
);

reg [20:0] count;


initial begin
	s0 = 1; s1 = 1; OE = 0; count = 0; en_yellow = 0; red1 = 0; green1 = 0; blue1 = 0;
end

always @(posedge clK_1MHZ)begin
	case(COLOR_STATE)
		1'b0:begin
			if ((count < 2000000) && (EI == 4 || en_yellow)) begin
				if(pwm_signal) begin
					green_mi = 1; red_mi = 0; blue_mi = 0;
				end else begin
					green_mi = 0; red_mi = 1; blue_mi = 0;
				end
			   count <= count + 1;
				en_yellow = 1;
			end else begin
				green_mi = 0; red_mi = 0; blue_mi = 0;
				en_yellow = 0;
				count = 0;
			end
			 
			case(EI)
				2'b01:begin
					case(color)
						2'b1:begin
							red1 = 1; green1 = 0; blue1 = 0; 
						end
						2'b10:begin
							red1 = 0; green1 = 1; blue1 = 0; 
						end
						2'b11:begin
							red1 = 0; green1 = 0; blue1 = 1;
						end
					endcase
				end
				
				2'b10:begin
					case(color)
						2'b1:begin
							red2 = 1; green2 = 0; blue2 = 0; 
						end
						2'b10:begin
							red2 = 0; green2 = 1; blue2 = 0; 
						end
						2'b11:begin
							red2 = 0; green2 = 0; blue2 = 1;
						end
					endcase
				end
				
				2'b11:begin
					case(color)
						2'b1:begin
							red3 = 1; green3 = 0; blue3 = 0; 
						end
						2'b10:begin
							red3 = 0; green3 = 1; blue3 = 0; 
						end
						2'b11:begin
							red3 = 0; green3 = 0; blue3 = 1;
						end
					endcase
				end
			endcase
		end
		
		1'b1:begin
			if(done) begin
				 if (count < 1000000) begin
					  green1 = 1; green2 = 1; green3 = 1; green_mi = 1;
					  red1   = 0; red2   = 0; red3   = 0; red_mi   = 0;
					  blue1  = 0; blue2  = 0; blue3  = 0; blue_mi  = 0;
					  count <= count + 1;
				 end else if (count < 2000000) begin
					  green1 = 0; green2 = 0; green3 = 0; green_mi = 0;
					  red1   = 0; red2   = 0; red3   = 0; red_mi   = 0;
					  blue1  = 0; blue2  = 0; blue3  = 0; blue_mi  = 0;
					  count <= count + 1;
				 end else begin
					  count <= 0;
				 end
			end else begin
				green1 = 0; green2 = 0; green3 = 0; green_mi = 0;
				red1   = 0; red2   = 0; red3   = 0; red_mi   = 0;
				blue1  = 0; blue2  = 0; blue3  = 0; blue_mi  = 0;
			end
		end
		
		2'b10:begin
			green1 = 0; green2 = 0; green3 = 0; green_mi = 0;
			red1   = 0; red2   = 0; red3   = 0; red_mi   = 0;
			blue1  = 0; blue2  = 0; blue3  = 0; blue_mi  = 0;
		end
	endcase
end

assign {s2,s3} = filter; 
endmodule 