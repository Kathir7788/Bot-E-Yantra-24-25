/*
# Team ID:          3699
# Theme:            EcoMender Bot
# Author List:      NISHANTH, HARIKARAN, ADITHIYA, KATHIR
# Filename:         motor_driver
# File Description: entire controls are done 
# Global variables: 
	left_value,center_value,right_value: Line follower sensor readings
	clk_1MHZ: 1MHz clock signal
	pwm_signal: 500Hz pwm signal to rotate motor
	start_run: turns high after receiving first CSL msg
	bot_state: indicates the current state of the bot
	OBSTACLE_without_load  _detected: turns high when OBSTACLE_without_load   is detected
	pulse_width: Ton time for pwm_signal
	started: turns high after bot starts moving
	count: number of nodes count
	done: tuns high after completion of the run
*/

module motor_driver(
	input [11:0] left_value,center_value,right_value,
	input 		 clk_1MHZ,pwm_signal,start_run,
	output reg   ENA,ENB,AF,AB,BF,BB,
	input [5:0] present_node,
	input [5:0] previous_node,
	input [5:0] future_node,
	input [2:0] bot_state,
	input ir_data,
	input [5:0] EP,
	input [3:0] CPU_RUN_COUNT,
	output reg [3:0] pulse_width,
	output reg started,
	output reg [4:0] count,
	output reg done,
	output reg [1:0] obs_pick_drop
);

reg [3:0] state;
reg  en,en_turn;
reg [25:0] delay_count;
reg [2:0] en_pick;
reg right,left,center;
reg [2:0] lr_turn;

localparam PWM = 15;

localparam START              	= 3'b100,
			  FORWARD 		      	= 2'b01,
			  LEFT_TURN          	= 3'b101,
			  RIGHT_TURN  	      	= 2'b10,
			  DOTTED_LINE_11_10  	= 2'b11,
			  DOTTED_LINE_10_11  	= 3'b110,
			  UTURN_ACLK         	= 3'b111,
			  UTURN_CLK 				= 4'b1001,
			  UTURN              	= 4'b1010,
			  NODE               	= 4'b1000,
			  BIT_FRONT					= 4'b1110,
			  TURN_DELAY            = 4'b1111,
			  OBSTACLE_without_load = 4'b1011,
			  OBSTACLE_with_load 	= 4'b1101,
			  INITIAL            	= 2'b00,
			  END                	= 4'b1100;

initial begin
	ENA = 1; ENB = 1;
	AF = 0; AB = 0; BF = 0; BB =0;
	state = INITIAL; count = 0; en = 0;pulse_width = PWM; started = 0;
	done = 0; left = 0; right = 0;  delay_count = 0;
	obs_pick_drop = 1; en_pick = 0; lr_turn = 1;
end

always @(posedge clk_1MHZ) begin
	if(left_value < 1000	&& center_value > 1000 && right_value < 1000)begin
		center = 1; right = 0; left = 0;
	end else if(left_value > 1000	&& center_value < 1000 && right_value < 1000) begin
		center = 0; right = 0; left = 1;
	end else if(left_value < 1000	&& center_value < 1000 && right_value > 1000) begin
		center = 0; right = 1; left = 0;
	end
end

always @(posedge clk_1MHZ) begin
	
	case (state) 
		OBSTACLE_without_load  : begin 
			if(en_pick == 1) begin 
				if(en_turn)begin
					obs_pick_drop = 1;
					if(delay_count < 500000) begin
						AF = 0; AB = 0; BF = 0; BB = 0;
						delay_count = delay_count + 1;
						
					end else if(delay_count < 1000000)begin
						if(pwm_signal)begin
							if(present_node == 1 && future_node == 11)begin
								AF = 1; AB = 0; BF = 0; BB = 1;
							end else begin
								AF = 0; AB = 1; BF = 1; BB = 0;
							end
						end else begin
							AF = 0; AB = 0; BF = 0; BB = 0;
						end
						delay_count = delay_count + 1;
					end else if(delay_count < 1500000)begin
						AF = 0; AB = 0; BF = 0; BB = 0;
						delay_count = delay_count + 1;
					end else if(delay_count == 1500000) begin
						en_turn = 0;
					end
				end else begin
					if(left_value < 1000	&& center_value > 1000 && right_value < 1000)begin
						state = FORWARD;
						obs_pick_drop = 0;
						en_pick = 0;
					end else begin 
						if(pwm_signal)begin
							if(present_node == 1 && future_node == 11)begin
								AF = 0; AB = 1; BF = 1; BB = 0;
							end else begin
								AF = 1; AB = 0; BF = 0; BB = 1;
							end
						end else begin
							AF = 0; AB = 0; BF = 0; BB = 0;
						end
					end
				end
			end else begin
				if(delay_count < 150000)begin
					AF = 0; AB = 1; BF = 0; BB = 1;
					delay_count = delay_count + 1;
				end else if(delay_count == 150000)begin
					delay_count = 0;
					en_pick = 1;
				end
			end
		end
		
		OBSTACLE_with_load :begin
			if(en_pick == 1)begin
				if(en_turn)begin
					obs_pick_drop = 2;
					if(delay_count < 500000) begin
						AF = 0; AB = 0; BF = 0; BB = 0;
						delay_count = delay_count + 1;
					end else if(delay_count < 1000000)begin
						if(pwm_signal)begin
							if(present_node == 11 && future_node == 1)begin
								AF = 1; AB = 0; BF = 0; BB = 1;
							end else begin
								AF = 0; AB = 1; BF = 1; BB = 0;
							end
						end else begin
							AF = 0; AB = 0; BF = 0; BB = 0;
						end
						delay_count = delay_count + 1;
					end else if(delay_count < 1500000)begin
						AF = 0; AB = 0; BF = 0; BB = 0;
						delay_count = delay_count + 1;
					end else if(delay_count == 1500000) begin
						en_turn = 0;
					end
				end else begin
					if(left_value < 1000	&& center_value > 1000 && right_value < 1000)begin
						state = FORWARD;
						en_pick = 0;
						obs_pick_drop = 0;
					end else begin 
						if(pwm_signal)begin
							if(present_node == 1 && future_node == 11)begin
								AF = 0; AB = 1; BF = 1; BB = 0;
							end else begin
								AF = 1; AB = 0; BF = 0; BB = 1;
							end
						end else begin
							AF = 0; AB = 0; BF = 0; BB = 0;
						end
					end
				end
			end else begin
				if(delay_count < 50000)begin
					AF = 1; AB = 0; BF = 0; BB = 1;
					delay_count = delay_count + 1;
				end else if(delay_count == 50000)begin
					delay_count = 0;
					en_pick = 1;
				end
			end
		end
		
		START: begin
			if(left_value < 1000 && center_value > 1000 && right_value < 1000) begin
				state = FORWARD;
			end else begin 
				if(pwm_signal)begin
					if(present_node == 1)begin
						AF = 0; AB = 1; BF = 1; BB = 0;
					end else if(present_node == 0) begin
						AF = 1; AB = 0; BF = 0; BB = 1;
					end
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end
		end
		
		BIT_FRONT:begin
			if(delay_count < 100000)begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
				delay_count = delay_count + 1; 
				if(en) begin 
					count = count + 1;
					en = 0;
				end
			end else begin
				delay_count = 0;
				state = NODE;
			end
		end
		
		NODE : begin
			if(bot_state != 0) begin 
				AF = 0; AB = 0; BF = 0; BB =0;
			end else if(left_value > 1300 && center_value > 1300 && right_value > 1300 && bot_state == 0) begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
				
				if(en) begin 
					if((future_node == 5 || future_node == 4 || future_node == 3) && present_node == 2 ) state = BIT_FRONT;
					count = count + 1;
					en = 0;
				end
			end else begin
				en_turn = 1;
				delay_count = 0;
				if(bot_state == 3) begin state = END;
				end else if(present_node == 0 && future_node == 1)begin
					if(previous_node == 10) state = LEFT_TURN;
					else if(previous_node == 6) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 0 && future_node == 10)begin
					if(previous_node == 6) state = FORWARD;
					else if(previous_node == 1) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 0 && future_node == 6)begin
					if(previous_node == 10) state = FORWARD;
					else if(previous_node == 1) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 1 && future_node == 11)begin
					if(previous_node == 0) state = LEFT_TURN;
					else if(previous_node == 2) state = FORWARD;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 1 && future_node == 0)begin
					if(previous_node == 11) state = RIGHT_TURN;
					else if(previous_node == 2) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 1 && future_node == 2)begin
					if(previous_node == 0) state = RIGHT_TURN;
					else if(previous_node == 11) state = FORWARD;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 2 && future_node == 1)begin
					if(previous_node == 3) state = RIGHT_TURN;
					else if(previous_node == 4) state = FORWARD ;
					else if(previous_node == 5) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 2 && future_node == 3)begin
//					if(previous_node == )
//					else
					state = LEFT_TURN;
				end else if(present_node == 2 && future_node == 4)begin
//					if(previous_node == )
//					else
					state = FORWARD;
				end else if(present_node == 2 && future_node == 5)begin
//					if(previous_node == )
//					else
					state = RIGHT_TURN;
				end else if(present_node == 3 && future_node == 2)begin
//					if(previous_node == )
//					else
					state = UTURN_ACLK;
				end else if(present_node == 4 && future_node == 2)begin
//					if(previous_node == )
//					else
					state = UTURN_CLK;
				end else if(present_node == 5 && future_node == 2)begin
//					if(previous_node == )
//					else
					state = UTURN_ACLK;
				end else if(present_node == 6 && future_node == 0)begin
					if(previous_node == 7) state = RIGHT_TURN ;
					else if(previous_node == 8) state = FORWARD ;
					else if(previous_node == 9) state = LEFT_TURN ;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 6 && future_node == 7)begin
//					if(previous_node == ) 
//					else
					state = LEFT_TURN ;
				end else if(present_node == 6 && future_node == 8)begin	
//					if(previous_node == )
//					else
					state = FORWARD;
				end else if(present_node == 6 && future_node == 9)begin
//					if(previous_node == )
//					else
					state = RIGHT_TURN;
				end else if(present_node == 7 && future_node == 6)begin
//					if(previous_node == )
//					else
					state = UTURN_CLK ;
				end else if(present_node == 8 && future_node == 6)begin
//					if(previous_node == )
//					else
					state = UTURN_ACLK ;
				end else if(present_node == 9 && future_node == 6)begin
//					if(previous_node == )
//					else
					state = UTURN_CLK ;
				end else if(present_node == 10 && future_node == 0)begin
					if(previous_node == 11) state = LEFT_TURN ;
					else if(previous_node == 24) state = FORWARD ;
					else if(previous_node == 26) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 10 && future_node == 11)begin
					if(previous_node == 0) state = RIGHT_TURN;
					else if(previous_node == 24) state = LEFT_TURN;
					else if(previous_node == 26) state = DOTTED_LINE_10_11;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 10 && future_node == 24)begin
					if(previous_node == 0) state = FORWARD ;
					else if(previous_node == 11) state = RIGHT_TURN;
					else if(previous_node == 26) state = LEFT_TURN ;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 10 && future_node == 26)begin
					if(previous_node == 0) state = LEFT_TURN ;
					else if(previous_node == 11) state = FORWARD;
					else if(previous_node == 24) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 11 && future_node == 10)begin
					if(previous_node == 1) state = LEFT_TURN;
					else if(previous_node == 12) state = DOTTED_LINE_11_10;
					else if(previous_node == 19) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 11 && future_node == 1)begin
					if(previous_node == 10) state = RIGHT_TURN;
					else if(previous_node == 12) state = LEFT_TURN;
					else if(previous_node == 19) state = FORWARD;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 11 && future_node == 12)begin
					if(previous_node == 1) state = RIGHT_TURN;
					else if(previous_node == 10) state = FORWARD;
					else if(previous_node == 19) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 11 && future_node == 19)begin
					if(previous_node == 1) state = FORWARD;
					else if(previous_node == 10) state = LEFT_TURN;
					else if(previous_node == 12) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 12 && future_node == 11)begin
					if(previous_node == 13) state = RIGHT_TURN;
					else if(previous_node == 14) state = FORWARD;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 12 && future_node == 13)begin
					if(previous_node == 11) state = LEFT_TURN;
					else if(previous_node == 14) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 12 && future_node == 14)begin
					if(previous_node == 11) state = FORWARD;
					else if(previous_node == 13) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 13 && future_node == 12)begin
//					if(previous_node == )
//					else
					state = UTURN_CLK;
				end else if(present_node == 14 && future_node == 12)begin
					if(previous_node == 15) state = RIGHT_TURN;
					else if(previous_node == 16) state = FORWARD;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 14 && future_node == 15)begin
					if(previous_node == 16) state = RIGHT_TURN;
					else if(previous_node == 12) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 14 && future_node == 16)begin
					if(previous_node == 12) state = FORWARD;
					else if(previous_node == 15) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 15 && future_node == 14)begin
//					if(previous_node == ) 
//					else
					state = UTURN_CLK;
				end else if(present_node == 16 && future_node == 14)begin
					if(previous_node == 17) state = RIGHT_TURN;
					else if(previous_node == 18) state = FORWARD;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 16 && future_node == 17)begin
					if(previous_node == 14) state = LEFT_TURN;
					else if(previous_node == 18) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 16 && future_node == 18)begin
					if(previous_node == 14) state = FORWARD;
					else if(previous_node == 17) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 17 && future_node == 16)begin
//					if(previous_node == ) 
//					else
					state = UTURN_CLK;
				end else if(present_node == 18 && future_node == 16)begin
					if(previous_node == 19) state = RIGHT_TURN;
					else if(previous_node == 21) state = FORWARD;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 18 && future_node == 19)begin
					if(previous_node == 16) state = LEFT_TURN;
					else if(previous_node == 21) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 18 && future_node == 21)begin
					if(previous_node == 16) state = FORWARD;
					else if(previous_node == 19) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 19 && future_node == 20)begin
					if(previous_node == 18) state = RIGHT_TURN;
					else if(previous_node == 11) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 19 && future_node == 18)begin
					if(previous_node == 11) state = FORWARD;
					else if(previous_node == 20) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 19 && future_node == 11)begin
					if(previous_node == 18) state = FORWARD;
					else if(previous_node == 20) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 20 && future_node == 19)begin
//					if(previous_node == )
//					else
					state = UTURN_CLK;
				end else if(present_node == 21 && future_node == 22)begin
					if(previous_node == 18) state = LEFT_TURN;
					else if(previous_node == 23) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 21 && future_node == 18)begin
					if(previous_node == 22) state = RIGHT_TURN;
					else if(previous_node == 23) state = FORWARD;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 21 && future_node == 23)begin
					if(previous_node == 18) state = FORWARD;
					else if(previous_node == 22) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 22 && future_node == 21)begin
//					if(previous_node == ) 
//					else
					state = UTURN_CLK;
				end else if(present_node == 23 && future_node == 21)begin
					if(previous_node == 24) state = RIGHT_TURN;
					else if(previous_node == 30) state = FORWARD;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 23 && future_node == 24)begin
					if(previous_node == 21) state = LEFT_TURN;
					else if(previous_node == 30) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 23 && future_node == 30)begin
					if(previous_node == 21) state = FORWARD;
					else if(previous_node == 24) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 24 && future_node == 25)begin
					if(previous_node == 10) state = RIGHT_TURN; 
					else if(previous_node == 23) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 24 && future_node == 23)begin
					if(previous_node == 10) state = FORWARD;
					else if(previous_node == 25) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 24 && future_node == 10)begin
					if(previous_node == 23) state = FORWARD;
					else if(previous_node == 25) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 25 && future_node == 24)begin
//					if(previous_node == ) 
//					else
					state = UTURN_CLK;
				end else if(present_node == 26 && future_node == 10)begin
					if(previous_node == 27) state = LEFT_TURN;
					else if(previous_node == 28) state = FORWARD;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 26 && future_node == 27)begin
					if(previous_node == 10) state = RIGHT_TURN;
					else if(previous_node == 28) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 26 && future_node == 28)begin
					if(previous_node == 10) state = FORWARD; 
					else if(previous_node == 27) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 27 && future_node == 26)begin
//					if(previous_node == )
//					else
					state = UTURN_CLK;
				end else if(present_node == 28 && future_node == 26)begin
					if(previous_node == 29) state = LEFT_TURN;
					else if(previous_node == 30) state = FORWARD;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 28 && future_node == 29)begin
					if(previous_node == 26) state = RIGHT_TURN;
					else if(previous_node == 30) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 28 && future_node == 30)begin
					if(previous_node == 26) state = FORWARD; 
					else if(previous_node == 29) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 29 && future_node == 28)begin
//					if(previous_node == ) 
//					else
					state = UTURN_CLK;
				end else if(present_node == 30 && future_node == 28)begin
					if(previous_node == 23) state = FORWARD;
					else if(previous_node == 31) state = LEFT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 30 && future_node == 31)begin
					if(previous_node == 23) state = LEFT_TURN;
					else if(previous_node == 28) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 30 && future_node == 23)begin
					if(previous_node == 28) state = FORWARD; 
					else if(previous_node == 31) state = RIGHT_TURN;
					else if(previous_node == future_node) state = UTURN;
				end else if(present_node == 31 && future_node == 30)begin
//					if(previous_node == )
//					else
					state = UTURN_CLK;
				end
			end
		end
		
		FORWARD:begin
			if(ir_data == 0 && EP != future_node && future_node != previous_node) begin
				state = OBSTACLE_without_load ;
				delay_count = 0;
				en_turn = 1;
			end else if(left_value > 1600 && center_value > 1600 && right_value > 1600)begin
				 state = NODE;
				delay_count = 0;
			end else if (left_value < 500 && center_value < 500 && right_value < 500)begin
				if(right == 1) begin
					if(pwm_signal)begin
						AF = 0; AB = 1; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end else if(left == 1) begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 0; BB = 1;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end
			end else if(left_value < 1200 && center_value > 1200 && right_value < 1200)begin
				en = 1;
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1200 && center_value < 1200 && right_value < 1200)begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 0; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 1200 && center_value < 1200 && right_value > 1200)begin
				if(pwm_signal)begin
					AF = 0; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < 1200 && center_value > 1200 && right_value > 1200) begin
				if(pwm_signal)begin
//					AF = 0; AB = 1; BF = 1; BB = 0;
					AF = 0; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value > 1200 && center_value > 1200 && right_value < 1200) begin
				if(pwm_signal)begin
//					AF = 1; AB = 0; BF = 0; BB = 1;
					AF = 1; AB = 0; BF = 0; BB = 0;
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
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end else if(left_value < right_value)begin
				if(pwm_signal)begin
					AF = 1; AB = 0; BF = 1; BB = 0;
				end else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end
		end
		
		RIGHT_TURN: begin
			if(en_turn)begin
				if(left_value > 1000 && center_value > 1000 && right_value > 1000) begin
						if(pwm_signal)begin
							AF = 1; AB = 0; BF = 1; BB = 0;
						end else begin
							AF = 0; AB = 0; BF = 0; BB =0;
						end
				end else if((left_value < 600 && center_value < 600 && right_value < 600) ||(left_value < 1200 && center_value < 1200 && right_value > 1200))begin
					en_turn = 0;
				end else begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 0; BB = 1;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end
			end else begin 
				if((left_value > 1400 && center_value < 1400 && right_value < 1400))begin
					if(present_node == 10 && future_node == 11) state = DOTTED_LINE_10_11;
					else if(present_node == 11 && future_node == 10) state = DOTTED_LINE_11_10;
					else state = FORWARD;
					lr_turn = 1;
				end else begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 0; BB = 1;
					end else begin
						AF = 1; AB = 0; BF = 0; BB =0;
					end
				end
			end
		end
		
		LEFT_TURN:begin
			if(en_turn)begin
				if(left_value > 1000 && center_value > 1000 && right_value > 1000) begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end else if((left_value < 600 && center_value < 600 && right_value < 600) ||(left_value > 1200 && center_value < 1200 && right_value < 1200))begin
					en_turn = 0;
				end else begin
					if(pwm_signal)begin
						AF = 0; AB = 1; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 1; BB =0;
					end
				end
			end else begin
				if((left_value < 1400 && center_value < 1400 && right_value > 1400)) begin
					if(present_node == 10 && future_node == 11) state = DOTTED_LINE_10_11;
					else if(present_node == 11 && future_node == 10) state = DOTTED_LINE_11_10;
					else state = FORWARD;
					lr_turn = 1;
				end else begin
					if(pwm_signal)begin
						AF = 0; AB = 1; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end
			end
		end
		
		UTURN_CLK:begin
			if(en_turn)begin
				if(left_value < 500 && center_value < 500 && right_value < 500)begin
					en_turn = 0;
				end else begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end
			end else begin
				if(left_value < 1000 && center_value > 1000 && right_value < 1000)begin
					state = FORWARD;
				end else begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 0; BB = 1;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end
			end
		end
		
		UTURN_ACLK:begin
			if(en_turn)begin
				if(left_value < 500 && center_value < 500 && right_value < 500)begin
					en_turn = 0;
				end else begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end
			end else begin
				if(left_value < 1000 && center_value > 1000 && right_value < 1000)begin
					state = FORWARD;
				end else begin
					if(pwm_signal)begin
						AF = 0; AB = 1; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end
			end
		end
		
		UTURN:begin
			if(en_turn) begin
				if(left_value > 1600 && center_value > 1600 && right_value > 1600)begin
					en_turn = 0;
				end else begin
					AF = 0; AB = 1; BF = 0; BB = 1;
				end
			end else begin
				if(left_value < 1000 && center_value > 1400 && right_value < 1000)begin
					state = FORWARD;
				end else begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 0; BB = 1;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end
			end
		end
		
		DOTTED_LINE_11_10: begin
			if(en_turn)begin
				if(left_value > 1000 && center_value < 1000 && right_value < 1000) en_turn = 0;
				else begin
					if(pwm_signal)begin
						AF = 0; AB = 1; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB = 0;
					end
				end
			end else begin
				if((left_value > 500 && center_value < 500 && right_value < 500) || (left_value < 1000 && center_value > 1000 && right_value < 1000))begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB = 0;
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
				end else if(left_value > 1500 && center_value > 1500 && right_value > 1500) begin
					state = NODE;
					en_turn = 1;
					en = 1;
				end
			end
		end
		
		DOTTED_LINE_10_11:begin
			if(en_turn)begin
				if(left_value < 1000 && center_value < 1000 && right_value > 1000) en_turn = 0;
				else begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 0; BB = 1;
					end else begin
						AF = 0; AB = 0; BF = 0; BB = 0;
					end
				end
			end else begin
				if((left_value < 500 && center_value < 500 && right_value > 500) || (left_value < 1000 && center_value > 1000 && right_value < 1000))begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end else if((left_value <1000 && center_value < 1000 && right_value > 1000))begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end else if((left_value > 1000 && center_value < 1000 && right_value < 1000) ||(left_value < 1000 && center_value > 1000 && right_value > 1000)|| (left_value > 1000 && center_value < 1000 && right_value > 1000))begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 0; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end else if(left_value > 1000 && center_value > 1000 && right_value < 1000) begin
					if(pwm_signal)begin
						AF = 1; AB = 0; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end else if(left_value < 500 && center_value < 500 && right_value < 500) begin
					if(pwm_signal)begin
						AF = 0; AB = 0; BF = 1; BB = 0;
					end else begin
						AF = 0; AB = 0; BF = 0; BB =0;
					end
				end else if(left_value > 1600 && center_value > 1600 && right_value > 1600)begin
					state = NODE;
					en_turn = 1;
					en = 1;
				end  else begin
					AF = 0; AB = 0; BF = 0; BB =0;
				end
			end
		end
		
		INITIAL: begin
			if(start_run) begin 	
				state = START;
				started = 1;
			end else started = 0;
		end
		
		END: done = 1;
	endcase
end
	
endmodule 