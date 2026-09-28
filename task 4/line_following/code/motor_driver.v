module motor_driver(
	input [11:0] left_value,center_value,right_value,
	input 		 clk_1MHZ,pwm_signal,
	output reg   ENA,ENB,AF,AB,BF,BB,
	output reg [3:0] pulse_width
);

reg [5:0] count;
reg [3:0] state;
reg  en,en_turn;
reg [1:0] lap_count;

localparam PWM = 5'b1111;

localparam START        = 2'b00,
			  FORWERD 		= 2'b01,
			  RIGHT_TURN  	= 2'b10,
			  DOTTED_LINE  = 2'b11,
			  DOTTED_LINE_11_10  = 2'b11,
			  DOTTED_LINE_10_11  = 3'b110,
			  END          = 3'b100;

initial begin
	ENA = 1; ENB = 1;
	AF = 0; AB = 0; BF = 0; BB =0;
	 state = 0; count = 0; en = 0; lap_count = 0; pulse_width = 20; 
end

always @(posedge clk_1MHZ) begin
	case (state)
		START : begin
			pulse_width = PWM;
			if(pwm_signal)begin
				AF = 1; AB = 0; BF = 1; BB = 0;
			end else begin
				AF = 0; AB = 0; BF = 0; BB =0;
			end
			if(en) begin 
				count = count + 1;
				en = 0;
			end
			
			if(count == 2 || count == 4 || count == 6) state = RIGHT_TURN;
			else if((left_value < 1000 && center_value > 1000 && right_value < 1000))begin
				if(count == 0 && (lap_count == 1 || lap_count == 2)) state = RIGHT_TURN;
				else state = FORWERD;
			end else if((left_value > 1000 && center_value < 1000 && right_value < 1000))begin
				if(count == 0 && (lap_count == 1 || lap_count == 2)) state = RIGHT_TURN;
				else state = FORWERD;
			end else if((left_value < 1000 && center_value < 1000 && right_value > 1000))begin 
				if(count == 0 && (lap_count == 1 || lap_count == 2)) state = RIGHT_TURN;
				else state = FORWERD;
			end else if(left_value > 1500 && center_value > 1500 && right_value > 1500) state = START;	
		end
		
		FORWERD:begin
			if(left_value > 1500 && center_value > 1500 && right_value > 1500)begin
				state = START;
			end else if (left_value < 500 && center_value < 500 && right_value < 500)begin
				AF = 0; AB = 0; BF = 0; BB =0;
			end else if(left_value < 1000 && center_value > 1000 && right_value < 1000)begin
				pulse_width = PWM;
				en = 1;
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1000 && center_value < 1000 && right_value < 1000)begin
				pulse_width = PWM;
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 1000 && center_value < 1000 && right_value > 1000)begin
				pulse_width = PWM;
				if(pwm_signal)begin
					AF = 0; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 1000 && center_value > 1500 && right_value > 1000) begin
				pulse_width = PWM;
				if(pwm_signal)begin
					AF = 0; AB = 1; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1000 && center_value > 1500 && right_value < 1000) begin
				pulse_width = PWM;
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 1;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < center_value && right_value < center_value)begin
				pulse_width = PWM;
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > right_value) begin
				pulse_width = PWM;
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < right_value)begin
				pulse_width = PWM;
				if(pwm_signal)begin
					AF = 0; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end
		end
		
		RIGHT_TURN: begin
			if(count == 0 && (lap_count == 1 || lap_count == 2) && en_turn)begin
				if(left_value > 1500 && center_value > 1500 && right_value > 1500) begin
						pulse_width = PWM;
						if(pwm_signal)begin
							AF = 1; AB = 0; BF = 1; BB = 0;
						end else begin
							AF = 0; AB = 0; BF = 0; BB =0;
						end
				end else if(left_value < 500 && center_value < 500 && right_value < 500)begin
					en_turn = 0;
				end else begin
				 pulse_width = PWM;
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 0; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end
			end else begin
				if((left_value < 1000 && center_value > 1000 && right_value < 1000)) begin
					if(count == 6) state = DOTTED_LINE;
					else if(count == 0 && lap_count == 2) state = END;
					else state = FORWERD;
				end else begin
					pulse_width = PWM;
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 0; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end
			end
		end
		
		DOTTED_LINE: begin
			if(left_value < 1000 && center_value > 1000 && right_value < 1000)begin
				pulse_width = PWM;	
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1000 && center_value < 1000 && right_value < 1000)begin
				pulse_width = PWM;
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 500 && center_value < 500 && right_value < 500)begin
				pulse_width = PWM;
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 1000 && center_value > 1000 && right_value > 1000) begin
				pulse_width = PWM;
				if(pwm_signal)begin
					AF = 0; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1000 && center_value > 1000 && right_value < 1000) begin 
				pulse_width = PWM;
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 1000 && center_value < 1000 && right_value > 1000)begin
				pulse_width = PWM;
				if(pwm_signal)begin
					AF = 0; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1500 && center_value > 1500 && right_value > 1500)begin
				state = START;
				lap_count = lap_count + 1; 
				count = 0;
				en_turn = 1;
			end
		end
		
		DOTTED_LINE_11_10: begin
			if((left_value > 500 && center_value < 500 && right_value < 500) || (left_value < 1000 && center_value > 1000 && right_value < 1000))begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1000 && center_value < 1000 && right_value < 1000)begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 1000 && center_value > 1000 && right_value > 1000) begin
				if(pwm_signal)begin
					AF = 0; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1000 && center_value > 1000 && right_value < 1000) begin 
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 1000 && center_value < 1000 && right_value > 1000)begin
				if(pwm_signal)begin
					AF = 0; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 500 && center_value < 500 && right_value < 500)begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1600 && center_value > 1600 && right_value > 1600) begin
				state = NODE;
				en_turn = 1;
			end
		end
		
		DOTTED_LINE_10_11:begin
			if((left_value < 500 && center_value < 500 && right_value > 500) || (left_value < 1000 && center_value > 1000 && right_value < 1000))begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 1000 && center_value < 1000 && right_value > 1000)begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1000 && center_value > 1000 && right_value < 1000) begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 1000 && center_value > 1000 && right_value > 1000) begin 
				if(pwm_signal)begin
					AF = 0; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1000 && center_value < 1000 && right_value < 1000)begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 500 && center_value < 500 && right_value < 500)begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1600 && center_value > 1600 && right_value > 1600)begin
				state = NODE;
				en_turn = 1;
			end
		end
		
		END: begin
			if(left_value < 1000 && center_value > 1000 && right_value < 1000) begin
				AF = 0; AB = 1; BF = 0; BB =1;
			end else begin
				AF = 0; AB = 0; BF = 0; BB =0;
			end
		end
	endcase
end
	
endmodule 