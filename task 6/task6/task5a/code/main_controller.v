/*
# Team ID:          3699
# Theme:            EcoMender Bot
# Author List:      NISHANTH, HARIKARAN, ADITHIYA, KATHIR
# Filename:         main_controller
# File Description: entire controls are/*
# Team ID:          3699
# Theme:            EcoMender Bot
# Author List:      NISHANTH, HARIKARAN, ADITHIYA, KATHIR
# Filename:         main_controller
# File Description: entire controls are done 
# Global variables: 
	clk_3125 : clock domain working
	rx_complete: rx complete given from uart_rx after all data is received
	rx_data: the data that is received via uart_rx
	started: to reset start_run to zero
	color: final color after sensing while travelling
	node: number of nodes travelled
	tx_done: indicates transmission of data via uart_tx
	en_yellow: to turn on yellow light when CSL msg is received
	ir_data: ir sensor readings
	start_run: turns high when first CSL msg is received
	tx_start: to trigger transmission of data via uart_tx
	tx_data: data to be transmitted via uart_tx
	SP: Start Point for CPU to find path
	EP: End Point for CPU to find path
	cpu_en: triggers the CPU to generate path_planned array 
	COLOR_STATE: triggers all green leds to blink during end run
	bot_state: states in which bot go during the traversal
	pwm_out1: control signal of servo 1
	pwm_out2: control signal of servo 2
   EI: Event Indicator 
	color_to_glow: which color to glow for respective sub unit
	obstacle_detected: turns high when obstacle is detected while travelling
	reset_var: reset all variable once a sub-unit is properly aided
*/



module main_controller(
	input clk_3125, rx_complete,
	input [7:0] rx_data,
	input started,
	input [1:0] color,
	input [4:0] node,
	input tx_done,
	input MemWrite,
	input reset,
	input [31:0] DataAdr,
	input [31:0] WriteData,
	input en_yellow,
	output reg start_run,tx_start,
	output reg [7:0] tx_data,
	output reg en_path,
	output reg [5:0] present_node,
	output reg [5:0] previous_node,
	output reg [5:0] future_node,
	output reg [5:0] SP,
	output reg [5:0] EP,
	output reg cpu_en,
	output reg [2:0] COLOR_STATE,
	output reg [2:0] bot_state,
	output reg pwm_out1,
	output reg pwm_out2,
   output reg [2:0] EI,
	output reg [1:0] color_to_glow,
	output reg reset_var,
	input [1:0] obs_pick_drop,
	input obstacle
);

reg [15:0] counter;      // Counter for the 20 ms period
reg [30:0] five_sec;
reg [7:0] num1,num2;
reg up_down1;
reg up_down2;
reg pick_drop;

reg en_color;

reg [2:0] en,en_print; // to select with message to sent to EC
reg [8:0] count;		  // used to find the gap between the message send
reg [8:0] PATH_PLANNED[0:15]; //path the EB go
reg [7:0] data_buffer [0:22]; //recive message from EC 
reg [7:0] CSL_WU[0:8],CSL_FU[0:8],CSL_PU[0:8];//pre-defined path for each subunit
integer counter_1,counter_2,count_4,reset_1,reset_2; // integers to reset the registers
reg [3:0] CPU_RUN_COUNT,pick_mess; // 'x' count to find weather to pick or place,'y' to send message   
reg [4:0] pre_node; 
reg [1:0] precolor;
reg [7:0] SLM[0:3]; // slm hex-value
reg [7:0] IM_AS_IS[0:5]; //red_discription ,green_discription ,blue_discription
reg [7:0] FSU[0:2],PSU[0:2],WSU[0:2];//  fsu, psu and wsu hex-value
reg [7:0] POINTS[0:5]; //after finding the sustainability level for one unit it will have all the   
reg [2:0] POINTS_INDEX;
reg [3:0] counter_3,NO_OF_WORK; //'counter_3' used as counter,'NO_OF_WORK' used to count how many sustainity level is not green in sub unit 
reg [4:0] index;

reg [7:0] END[0:4]; // END-# message
reg [7:0] PICK_DROP[0:26],PICK_DROP_samp[0:26];//RPM or RDM sub_unit name
reg [7:0] RPM[0:2];
reg [7:0] RDM[0:2];
reg CSL_UNIT_RUN,WU,FU,PU,csl_done;
reg [1:0] csl_run;//i assumed WSU = 1 FSU = 2 PSU = 3 so after resived the csl acoding to the messaeg csl_run will becom the respective number

initial begin
	en = 0; en_path = 0; counter_1=0; counter_2=0; counter_3=0; pick_mess=0; counter_3=0; bot_state = 0; previous_node = 0; start_run = 0;
	pre_node = 0; cpu_en = 0;  precolor = 0; index = 0; COLOR_STATE = 0; en_print = 0; 
	five_sec = 0; CSL_UNIT_RUN = 0; num1 = 0; num2 = 0; up_down1 = 1; up_down2 = 1;//return_en = 1; i=0;
	
	pick_drop = 0; WU = 0; FU = 0; PU = 0; csl_done = 0; csl_run = 0; NO_OF_WORK = 0; en_color = 0;
	
	CSL_WU[0] = 1;
	CSL_WU[1] = 11;
	CSL_WU[2] = 19;
	CSL_WU[3] = 18;
	CSL_WU[4] = 16;
	CSL_WU[5] = 14;
	CSL_WU[6] = 12;
	CSL_WU[7] = 11;
	CSL_WU[8] = 63;
	
	CSL_FU[0] = 0;
	CSL_FU[1] = 10;
	CSL_FU[2] = 24;
	CSL_FU[3] = 23;
	CSL_FU[4] = 21;
	CSL_FU[5] = 18;
	CSL_FU[6] = 19;
	CSL_FU[7] = 11;
	CSL_FU[8] = 63;
	
	CSL_PU[0] = 0;
	CSL_PU[1] = 10;
	CSL_PU[2] = 26;
	CSL_PU[3] = 28;
	CSL_PU[4] = 30;
	CSL_PU[5] = 23;
	CSL_PU[6] = 24;
	CSL_PU[7] = 10;
	CSL_PU[8] = 63;
	
	SLM[0] = "S";
	SLM[1] = "L";
	SLM[2] = "M";
	
	IM_AS_IS[0] = "I";
	IM_AS_IS[1] = "M";
	IM_AS_IS[2] = "A";
	IM_AS_IS[3] = "S";
	IM_AS_IS[4] = "I";
	IM_AS_IS[5] = "S";
	
	WSU[0] = "W";
	WSU[1] = "S";
	WSU[2] = "U";
	
	FSU[0] = "F";
	FSU[1] = "S";
	FSU[2] = "U";
	
	PSU[0] = "P";
	PSU[1] = "S";
	PSU[2] = "U";
	
	END[0] = "E";
	END[1] = "N";
	END[2] = "D";
	END[3] = "-";
	END[4] = "#";
	
	RPM[0] = "R";
	RPM[1] = "P";
	RPM[2] = "M";
	
	RDM[0] = "R";
	RDM[1] = "D";
	RDM[2] = "M";
	
	for(reset_1 = 0; reset_1 < 27;reset_1 = reset_1 + 1) begin
		PICK_DROP[reset_1] <= 0;
		PICK_DROP_samp[reset_1] <= 0;
	end
	
	counter = 0;
	pwm_out1 = 0;
	pwm_out2 = 0;
end

always @(posedge clk_3125) begin
	case(en_print)
		2'b00:begin 
			counter_1 <= 0;
			if(EP == present_node && (WU == 0 || PU == 0 || FU == 0) && csl_done) begin
				if(count == 297) begin
					en <= 2;
					count = 0;
				end
				count = count + 1;
			end else if(reset_var)begin
				for(reset_1 = 0; reset_1 < 27; reset_1 = reset_1 + 1) PICK_DROP_samp[reset_1]<= 0;
				NO_OF_WORK = 0;
				count = 0;
				en <= 0;
				pick_mess = 0;
				EI = 0;
			end else begin 
				count = 0;
				en <= 0;
			end 
		end
		2'b01:begin
			if(count == 297) begin
				if(counter_1 < 3)begin
					tx_data <= SLM[counter_1];	
					tx_start <= 1;
					counter_1 <= counter_1 + 1;
					count <= 1;
				end else if(counter_1 == 3 || counter_1 == 11)begin
					tx_data <= "-";	// 8'b10110100
					tx_start <= 1;
					counter_1 <= counter_1 + 1;
					count <= 1;
				end else if(counter_1 > 3 && counter_1 < 7) begin
					if(csl_run == 1) tx_data <= WSU[counter_1-4];	
					else if(csl_run == 2) tx_data <= FSU[counter_1-4]; 
					else if(csl_run == 3) tx_data <= PSU[counter_1-4];
					tx_start <= 1;
					counter_1 <= counter_1 + 1;
					count <= 1;
				end else if(counter_1 == 7)begin
					if(csl_run == 1) begin
						if(present_node == 16) tx_data <= "1";
						else if(present_node == 14) tx_data <= "2";
						else if(present_node == 12) tx_data <= "3";
					end else if(csl_run == 2) begin
						if(present_node == 24) tx_data <= "1";
						else if(present_node == 21) tx_data <= "2";
						else if(present_node == 18) tx_data <= "3";
					end else if(csl_run == 3) begin
						if(future_node == 26) tx_data <= "1";
						else if(future_node == 28) tx_data <= "2";
						else if(future_node == 30) tx_data <= "3";
					end
					tx_start <= 1;
					counter_1 <= counter_1 + 1;
					count <= 1;
				end else if(counter_1 == 8)begin
					case(color)
						1:begin	
							NO_OF_WORK = NO_OF_WORK + 1;
							if(csl_run == 1) {PICK_DROP_samp[(POINTS_INDEX/2-1)*9],PICK_DROP_samp[(POINTS_INDEX/2-1)*9+1],PICK_DROP_samp[(POINTS_INDEX/2-1)*9+2],PICK_DROP_samp[(POINTS_INDEX/2-1)*9+3],PICK_DROP_samp[(POINTS_INDEX/2-1)*9+4]} = {"WSU",tx_data,"0"};
							else if(csl_run == 2) {PICK_DROP_samp[(POINTS_INDEX/2-1)*9],PICK_DROP_samp[(POINTS_INDEX/2-1)*9+1],PICK_DROP_samp[(POINTS_INDEX/2-1)*9+2],PICK_DROP_samp[(POINTS_INDEX/2-1)*9+3],PICK_DROP_samp[(POINTS_INDEX/2-1)*9+4]} = {"FSU",tx_data,"0"};
							else if(csl_run == 3) {PICK_DROP_samp[(POINTS_INDEX/2-1)*9],PICK_DROP_samp[(POINTS_INDEX/2-1)*9+1],PICK_DROP_samp[(POINTS_INDEX/2-1)*9+2],PICK_DROP_samp[(POINTS_INDEX/2-1)*9+3],PICK_DROP_samp[(POINTS_INDEX/2-1)*9+4]} = {"PSU",tx_data,"0"};
						end
						3:begin
							NO_OF_WORK = NO_OF_WORK + 1;
							if(csl_run == 1) {PICK_DROP_samp[(POINTS_INDEX/2)*9-5],PICK_DROP_samp[(POINTS_INDEX/2)*9-5+1],PICK_DROP_samp[(POINTS_INDEX/2)*9-5+2],PICK_DROP_samp[(POINTS_INDEX/2)*9-5+3],PICK_DROP_samp[(POINTS_INDEX/2)*9-5+4]} = {"WSU",tx_data,"0"};
							else if(csl_run == 2) {PICK_DROP_samp[(POINTS_INDEX/2)*9-5],PICK_DROP_samp[(POINTS_INDEX/2)*9-5+1],PICK_DROP_samp[(POINTS_INDEX/2)*9-5+2],PICK_DROP_samp[(POINTS_INDEX/2)*9-5+3],PICK_DROP_samp[(POINTS_INDEX/2)*9-5+4]} = {"FSU",tx_data,"0"};
							else if(csl_run == 3) {PICK_DROP_samp[(POINTS_INDEX/2)*9-5],PICK_DROP_samp[(POINTS_INDEX/2)*9-5+1],PICK_DROP_samp[(POINTS_INDEX/2)*9-5+2],PICK_DROP_samp[(POINTS_INDEX/2)*9-5+3],PICK_DROP_samp[(POINTS_INDEX/2)*9-5+4]} = {"PSU",tx_data,"0"};
						end
					endcase
					EI = tx_data;
					color_to_glow = color;
					tx_data <= "-";	// 8'b10110100
					tx_start <= 1;
					counter_1 <= counter_1 + 1;
					count <= 1;
				end else if(counter_1 > 8 && counter_1 < 11) begin
					tx_data <= IM_AS_IS[counter_1-9+2*(color-1)];	
					tx_start <= 1;
					counter_1 <= counter_1 + 1;
					count <= 1;
				end else if(counter_1 == 12)begin
					tx_data <= "#";//8'b11000100;	
					tx_start <= 1;
					counter_1 <= counter_1 + 1;
					count <= 1;
				end else begin
					en <= 1;
				end
			end	
			
			count <= count + 1; 
			if(count == 2) tx_start <= 0;
		end
		
		2'b11:begin
			if(count == 297)begin
				if(counter_1 < 3) begin
					if(CPU_RUN_COUNT%2 == 0) tx_data <= RPM[counter_1];
					else tx_data <= RDM[counter_1];
					tx_start <= 1;
					counter_1 = counter_1 + 1;
					count <= 1;
				end else if (counter_1 == 3 || counter_1 == 8) begin
					tx_data <= "-";	
					tx_start <= 1;
					counter_1 = counter_1 + 1;
					count <= 1;
				end else if(counter_1>3 && counter_1<8) begin
					if(PICK_DROP[pick_mess + 4] == "0") begin
						tx_data <= PICK_DROP[pick_mess + counter_1 - 4];
						if(counter_1 == 7) begin 
							if(CPU_RUN_COUNT%2 != 0)begin
								EI = PICK_DROP[pick_mess + counter_1 - 4]-"0";
								color_to_glow = 2;
							end
							pick_mess = pick_mess + 5;
						end
					end else if(PICK_DROP[pick_mess + 3] == "0") begin
						tx_data <= PICK_DROP[pick_mess + counter_1 - 4];
						if(counter_1 == 6) begin
							if(CPU_RUN_COUNT%2 != 0)begin
								EI = PICK_DROP[pick_mess + counter_1 - 8]-"0";
								color_to_glow = 2;
							end
							pick_mess = pick_mess + 4;
							counter_1 = counter_1 + 1;
						end	
					end
					tx_start <= 1;
					counter_1 = counter_1 + 1;
					count <= 1;
				end else if(counter_1 == 9)begin
					tx_data <= "#";	
					tx_start <= 1;
					counter_1 = counter_1 + 1;
					count <= 1;
				end else begin
					en <= 1;
				end
			end
			
			count <= count + 1; 
			if(count == 2) tx_start <= 0;
		end
		
		3'b100: begin
			if(count == 297) begin
				if(counter_1 < 5)begin
					tx_data <= END[counter_1];	
					tx_start <= 1;
					counter_1 <= counter_1 + 1;
					count <= 0;
				end
			end else if(count< 297) count <= count + 1;
			if(count == 2) tx_start <= 0;
		end
		
		3'b101:begin
			if(en_yellow)begin
				EI = 0;
				en = 1;
			end else EI = 4;
		end
	endcase
end

always @(posedge clk_3125) begin
	case(bot_state)
		2'b00:begin
		
			if(!obstacle) begin
				bot_state <= 4;
			end
			
			if(en == 1) en_print <= 0;
			if(NO_OF_WORK == 0) reset_var = 0;
			if(rx_complete) begin 
				data_buffer[counter_2] = {rx_data[0],rx_data[1],rx_data[2],rx_data[3],rx_data[4],rx_data[5],rx_data[6],rx_data[7]};
				counter_2 = counter_2 + 1;
			end
			
			if ({data_buffer[0],data_buffer[1],data_buffer[2],data_buffer[counter_2-1]}== "CSL#") begin
				if(data_buffer[4] == "W") WU = 1;
				else if(data_buffer[4] == "F") FU = 1;
				else if(data_buffer[4] == "P") PU = 1;
				
//				if(data_buffer[counter_2-1] == "#")begin
					for(reset_1=0;reset_1<8;reset_1 = reset_1 + 1) data_buffer[reset_1] = 0;
					counter_2 = 0;
					if(node == 0) csl_done = 1;
					en_print <= 5;
//				end
			end 
			else if({data_buffer[0],data_buffer[1],data_buffer[2],data_buffer[counter_2-1]} == "SAM#") begin
				POINTS_INDEX = 0;
				for(reset_1 = 0;reset_1 < 27;reset_1 = reset_1 + 1)PICK_DROP[reset_1] = PICK_DROP_samp[reset_1];
				for(reset_2 = 6;reset_2 < 21;reset_2 = reset_2 + 6) begin
					case ({data_buffer[reset_2], data_buffer[reset_2+2]})
						16'h4D31: begin 
							POINTS[counter_3*2+1] = 9; // "M1" -> ASCII: 0x4D ('M'), 0x31 ('1') 
							{PICK_DROP[counter_3*9+5],PICK_DROP[counter_3*9+5+1],PICK_DROP[counter_3*9+5+2],PICK_DROP[counter_3*9+5+3]} = "MU10"; 
							counter_3 = counter_3 + 1;
						end
						
						16'h4D32: begin
							POINTS[counter_3*2+1] = 8; // "M2" -> ASCII: 0x4D ('M'), 0x32 ('2')
							{PICK_DROP[counter_3*9+5],PICK_DROP[counter_3*9+5+1],PICK_DROP[counter_3*9+5+2],PICK_DROP[counter_3*9+5+3]} = "MU20";
							counter_3 = counter_3 + 1;
						end
						
						16'h4D33: begin
							POINTS[counter_3*2+1] = 7; // "M3" -> ASCII: 0x4D ('M'), 0x33 ('3')
							{PICK_DROP[counter_3*9+5],PICK_DROP[counter_3*9+5+1],PICK_DROP[counter_3*9+5+2],PICK_DROP[counter_3*9+5+3]} = "MU30";
							counter_3 = counter_3 + 1;
						end
						
						16'h5331: begin 
							POINTS[counter_3*2] = 5; // "S1" -> ASCII: 0x53 ('S'), 0x31 ('1')
							{PICK_DROP[counter_3*9],PICK_DROP[counter_3*9+1],PICK_DROP[counter_3*9+2],PICK_DROP[counter_3*9+3]} = "SU10";
							counter_3 = counter_3 + 1;
						end
						
						16'h5332: begin
							POINTS[counter_3*2] = 4; // "S2" -> ASCII: 0x53 ('S'), 0x32 ('2')
							{PICK_DROP[counter_3*9],PICK_DROP[counter_3*9+1],PICK_DROP[counter_3*9+2],PICK_DROP[counter_3*9+3]} = "SU20";
							counter_3 = counter_3 + 1;
						end
						
						16'h5333: begin 
							POINTS[counter_3*2] = 3; // "S3" -> ASCII: 0x53 ('S'), 0x33 ('3')
							{PICK_DROP[counter_3*9],PICK_DROP[counter_3*9+1],PICK_DROP[counter_3*9+2],PICK_DROP[counter_3*9+3]} = "SU30";
							counter_3 = counter_3 + 1;
						end
					endcase
				end
				counter_3 = 0;
//				if(data_buffer[counter_2-1] == "#")begin
					for(reset_1 = 0;reset_1 < 8;reset_1 = reset_1 + 1) data_buffer[reset_1] = 0;
					counter_2 = 0;
//				end
			end
			
			if(csl_done && (WU || FU || PU))begin
				if(WU) csl_run = 1;
				else if(FU) csl_run = 2;
				else if(PU) csl_run = 3;

				if (node == 0) begin
					if(WU) for(reset_1=0;reset_1<9;reset_1=reset_1+1) PATH_PLANNED[reset_1] = CSL_WU[reset_1];
					else if(FU) for(reset_1=0;reset_1<9;reset_1=reset_1+1) PATH_PLANNED[reset_1] = CSL_FU[reset_1];
					else if(PU) for(reset_1=0;reset_1<9;reset_1=reset_1+1) PATH_PLANNED[reset_1] = CSL_PU[reset_1];
					
					if(PATH_PLANNED[0] == 1) present_node = 0;
					else if(PATH_PLANNED[0] == 0) present_node = 1;
					future_node = PATH_PLANNED[0];
					start_run <= 1;
					if(started)	start_run <= 0;
				end else begin
					SP = present_node;
					EP = 0;
					bot_state <= 1;
					cpu_en <= 1;
					CPU_RUN_COUNT = 10;
					POINTS_INDEX = 0;
					for(reset_1 = 0; reset_1 < 6; reset_1 = reset_1 + 1) if(POINTS[reset_1] != 0) POINTS[reset_1] = 0;
					for(reset_1 = 0; reset_1 < 27; reset_1 = reset_1 + 1) PICK_DROP[reset_1] = 0;
				end		
				csl_done = 0;
			end else if(csl_done == 1 && WU == 0 && FU == 0 && PU == 0)begin
				COLOR_STATE = 1;
				bot_state <= 3;
			end
			
			if(precolor != color && !CSL_UNIT_RUN && !en_color) begin
				precolor = color;
				en_color = 1;
				case(color)
					2'b01:begin
						if(csl_run == 1) POINTS[POINTS_INDEX] = present_node+1;
						else if(csl_run == 2)begin
							if(present_node == 18) POINTS[POINTS_INDEX] = future_node+1;
							else POINTS[POINTS_INDEX] = present_node+1;
						end else if(csl_run == 3) POINTS[POINTS_INDEX] = future_node+1;
						POINTS_INDEX = POINTS_INDEX + 2; 
					end
					2'b11:begin
						POINTS_INDEX = POINTS_INDEX + 1;
						if(csl_run == 1) POINTS[POINTS_INDEX] = present_node+1;
						else if(csl_run == 2)begin
							if(present_node == 18) POINTS[POINTS_INDEX] = future_node+1;
							else POINTS[POINTS_INDEX] = present_node+1;
						end else if(csl_run == 3) POINTS[POINTS_INDEX] = future_node+1;
						POINTS_INDEX = POINTS_INDEX + 1;
					end
				endcase 
				if(!COLOR_STATE && color != 0)begin
					en_print <= 1;
				end 
			end

			if(node != pre_node) begin
				en_color = 0;
				index = index + 1;
				previous_node = present_node;
				present_node = future_node;
				COLOR_STATE = 0;
				if(PATH_PLANNED[index]==63 && CPU_RUN_COUNT < NO_OF_WORK * 2) begin//&& PATH_PLANNED[index+1]==63 to run cpu and find path
					if(CPU_RUN_COUNT == 0) CSL_UNIT_RUN = 1;
					index = 1;
					SP = present_node;
					EP = POINTS[CPU_RUN_COUNT];
					CPU_RUN_COUNT = CPU_RUN_COUNT + 1;
					if(CPU_RUN_COUNT != 1)begin
						if(CPU_RUN_COUNT%2 == 0) pick_drop <= 0;
						else pick_drop <= 1;
						bot_state <= 2;
					end else begin 
						cpu_en <= 1;
						bot_state <= 1;//state to cpu
					end
				end else if(CPU_RUN_COUNT == NO_OF_WORK * 2 && present_node == EP && NO_OF_WORK) begin//only to print the last RDM message
					en_print <= 3;
					index = 1;
					CPU_RUN_COUNT = CPU_RUN_COUNT+1;
					if(CPU_RUN_COUNT % 2 == 0) pick_drop = 0;
					else pick_drop = 1;
					bot_state <= 2;
					if(csl_run == 1) WU = 0;
					else if(csl_run == 2) FU = 0;
					else if(csl_run == 3) PU = 0;
				end else if(CPU_RUN_COUNT == 10 && present_node==EP)begin
					if(csl_run == 1) for(reset_1=0;reset_1<9;reset_1=reset_1+1) PATH_PLANNED[reset_1] = CSL_WU[reset_1];
					else if(csl_run == 2) for(reset_1=0;reset_1<9;reset_1=reset_1+1) PATH_PLANNED[reset_1] = CSL_FU[reset_1];
					else if(csl_run == 3) for(reset_1=0;reset_1<9;reset_1=reset_1+1) PATH_PLANNED[reset_1] = CSL_PU[reset_1];
					CPU_RUN_COUNT = 0;
					if(present_node == PATH_PLANNED[0])index = 1;
					else index = 0; 
					CSL_UNIT_RUN = 0;
					reset_var = 1;
					COLOR_STATE = 2;
				end
				future_node = PATH_PLANNED[index];
				pre_node = node;
			end 
		end
		
		2'b01:begin
			if(cpu_en) cpu_en <= 0;
			if(MemWrite && !reset) begin
				if (DataAdr === 32'h02000008) begin
					PATH_PLANNED[count_4] = WriteData;
					count_4 = count_4 + 1'b1;
				end
				if (DataAdr === 32'h0200000c & WriteData === 32'h1) begin
					PATH_PLANNED[count_4] = 63;
					future_node = PATH_PLANNED[1];
					bot_state <= 0;
					count_4 = 0;
				end
			end
		end
		
		2'b10: begin
			five_sec <= five_sec + 1;
			
			if(pick_drop == 0) begin //pick at node points
				case(five_sec) 
					1500000: up_down1 = 0;
					3000000: up_down2 = 0;
					4500000: up_down1 = 1;
					6000000: five_sec <= 0;
				endcase
			end else begin           //drop at node points
				case(five_sec) 
					1500000: up_down1 = 0;
					3000000: up_down2 = 1;
					4500000: up_down1 = 1;
					6000000: five_sec <= 0;
				endcase
			end
			if(CPU_RUN_COUNT == (NO_OF_WORK*2)+1 && present_node==EP && five_sec == 6000000)begin
				bot_state <= 0;
				csl_done <= 1;
			end else if(five_sec == 6000000) begin
				cpu_en <= 1;
				bot_state <= 1;
			end 
			
			if(five_sec == 6000000) en_print <= 3;//state to print RPM AND RDM message 
		end
		
		2'b11:begin
			if(en == 1) en_print <= 0;
			else if(en == 2) en_print <= 4;
		end
		
		2'b100: begin
			five_sec <= five_sec + 1;
			
			if(obs_pick_drop == 0) begin //pick obstacle
				case(five_sec) 
					1000000: up_down1 = 0;
					2000000: up_down2 = 0;
					3000000: up_down1 = 1;
					4000000: five_sec <= 0;
				endcase
			end else begin           //drop obstacle
				case(five_sec) 
					1000000: up_down1 = 0;
					2000000: up_down2 = 1;
					3000000: up_down1 = 1;
					4000000: begin
//						if(obstacle)begin
							five_sec <= 0;
//							bot_state <= 0;
//						end
					end
				endcase
			end
			
			if(obstacle) begin
				bot_state <= 0;
			end
		end
		
	endcase
end

always @(posedge clk_3125) begin

//	five_sec <= five_sec + 1;
//	
//	case(five_sec) 
//		 5000000: up_down1 = 1;
//		10000000: up_down2 = 1;
//		15000000: up_down1 = 0;
//		20000000: up_down1 = 1;
//		25000000: up_down2 = 0;
//		30000000: up_down1 = 0;
//		35000000: five_sec <= 0;
//	endcase
	
	if (counter >= 62500) begin
		counter <= 0;
	end else begin
		counter <= counter + 1;
	end
	
	if(up_down1 == 1) pwm_out1 <= (counter < 7500) ? 1 : 0; //(1250+((angle*625)/18))
	else pwm_out1 <= (counter < 4000) ? 1 : 0;
	
	if(up_down2 == 1) pwm_out2 <= (counter < 6500) ? 1 : 0; //(1250+((angle*625)/18))
	else pwm_out2 <= (counter < 3750) ? 1 : 0;	
	
end
endmodule













//	if(bot_state == 0)begin
//		if(ir_data == 0) begin
//			obstacle_detected = 1;
//		end
//		
//		if(obstacle_detected == 1) begin //pick block if obstacle detected
//			five_sec <= five_sec + 1;
//			case(five_sec) 
//				5000000: up_down2 = 1;
//				10000000: up_down1 = 1;
//				15000000: up_down2 = 0;
//				20000000: begin
//					five_sec <= 0;
//					obstacle_detected = 0;
//				end
//			endcase
//		end
//	end
