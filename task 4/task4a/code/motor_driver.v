module motor_driver(
	input [11:0] left_value,center_value,right_value,
	input 		 clk_1MHZ,pwm_signal,start_run,
	output reg   ENA,ENB,AF,AB,BF,BB,
	output reg [3:0] pulse_width,
	output reg   started,
	output reg [2:0] count,
	output reg done
);

reg [2:0] state;
reg  en,en_turn,left,right;
reg [1:0] lap_count;

localparam PWM = 15;

localparam START        = 3'b100,
			  FORWERD 		= 2'b01,
			  RIGHT_TURN  	= 2'b10,
			  DOTTED_LINE  = 2'b11,
			  END          = 2'b00;

initial begin
	ENA = 1; ENB = 1;
	AF = 0; AB = 0; BF = 0; BB =0;
	state = END; count = 0; en = 0; lap_count = 0; pulse_width = PWM; started = 0;
	done = 0; left = 0; right = 0; 
end

always @(posedge clk_1MHZ) begin
	case (state)
		START : begin
			if(left_value > 1500 && center_value > 1500 && right_value > 1500) begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
				if(en) begin 
					count = count + 1;
					en = 0;
				end
			end else begin
				if(count == 2 || count == 4 || count == 6) begin
					state = RIGHT_TURN;
					en_turn = 1;
				end else if(left_value > 1500 && center_value > 1500 && right_value > 1500) state = START;	
				else begin
					if(count == 0 && (lap_count == 1 || lap_count == 2)) state = RIGHT_TURN;
					else state = FORWERD;
				end
			end
		end
		
		FORWERD:begin
			if(left_value > 1500 && center_value > 1500 && right_value > 1500)begin
				state = START;
			end else if (left_value < 500 && center_value < 500 && right_value < 500)begin
				AF = 0; AB = 0; BF = 0; BB =0;
			end else if(left_value < 1000 && center_value > 1000 && right_value < 1000)begin
				en = 1;
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1000 && center_value < 1000 && right_value < 1000)begin
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
			end else if(left_value < 1000 && center_value > 1500 && right_value > 1000) begin
				if(pwm_signal)begin
					AF = 0; AB = 1; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1000 && center_value > 1500 && right_value < 1000) begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 1;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < center_value && right_value < center_value)begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > right_value) begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < right_value)begin
				if(pwm_signal)begin
					AF = 0; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end
		end
		
		RIGHT_TURN: begin
			if(en_turn)begin
				if(left_value > 1500 && center_value > 1500 && right_value > 1500) begin
						if(pwm_signal)begin
							AF = 1; AB = 0; BF = 1; BB = 0;
						end else begin
							AF = 0; AB = 0; BF = 0; BB =0;
						end
				end else if(left_value < 500 && center_value < 500 && right_value < 500)begin
					en_turn = 0;
				end else begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 0; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end
			end else begin
				if((left_value < 600 && center_value < 600 && right_value < 600)) begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 0; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end else begin
					if(count == 6) state = DOTTED_LINE;
					else if(count == 0 && lap_count == 2) begin
						state = END;
					end else state = FORWERD;
				end
			end
		end
		
		DOTTED_LINE: begin
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
			end else if(left_value > 1500 && center_value > 1500 && right_value > 1500)begin
				state = START;
				lap_count = lap_count + 1; 
				count = 0;
				en_turn = 1;
			end
		end
		
		END: begin
			if(start_run) begin 	
				state = START;
				started = 1;
			end else started = 0;
			
			if(left_value < 1000 && center_value < 1000 && right_value > 1000 && lap_count == 2)begin
				AF = 0; AB = 0; BF = 0; BB =0; 
				done <= 1;
			end else if(lap_count == 2) begin
				AF = 1; AB = 0; BF = 0; BB =0;
			end
		end
	endcase
end
	
endmodule 