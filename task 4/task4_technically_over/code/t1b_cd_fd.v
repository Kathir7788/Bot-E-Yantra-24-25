// EcoMender Bot : Task 1B : Color Detection using State Machines
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will detect colors red, green, and blue using state machine and frequency detection.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//Color Detection
//Inputs : clk_1MHz, cs_out
//Output : filter, color

// Module Declaration
module t1b_cd_fd (
    input  clk_1MHz, cs_out,
	 input [2:0] node,
    output reg [1:0] filter, color
);

// red   -> color = 1;
// green -> color = 2;
// blue  -> color = 3;

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////
localparam BLUE_FILTER = 2'b01,
				RED_FILTER = 2'b00,
				GREEN_FILTER = 2'b11,
				CLEAR_FILTER = 2'b10;
//reg state;
reg [10:0] clk_count;
reg [8:0] cs_out_count;
reg [6:0] green_cs_out;
reg [6:0] red_cs_out;
reg [6:0] blue_cs_out;
reg [1:0] filter_cs_out;
reg 		 en;

initial begin // editing this initial block is allowed
    filter = 3; color = 0; clk_count = 0;cs_out_count = 0; filter_cs_out = 0; en = 0; //count = 0;sample_cs_out = 0;
end

/*
Add your logic here
*/

always @(posedge cs_out)begin
	if(clk_count > 50 && clk_count < 495) cs_out_count <= cs_out_count + 1;
	if(clk_count < 100 && en)begin
		cs_out_count <= 0;
		en = 0;
	end
	if(cs_out_count == 0) en = 1;
end

always @(posedge  clk_1MHz)begin
	case(filter)
		GREEN_FILTER:begin
			if(clk_count < 500) clk_count <= clk_count+1;
			else begin 
				clk_count <= 1;
				filter <= RED_FILTER;
				green_cs_out <= cs_out_count;
			end
		end
		
		RED_FILTER:begin
			if(clk_count < 500) clk_count <= clk_count+1;
			else begin 
				clk_count <= 1;
				filter <= BLUE_FILTER;
				red_cs_out <= cs_out_count;
			end
		end
		
		BLUE_FILTER:begin
			if(clk_count < 500) clk_count <= clk_count+1;
			else begin 
				clk_count <= 1;
				filter <= CLEAR_FILTER;
				blue_cs_out <= cs_out_count;
			end
		end
		
		CLEAR_FILTER:begin
			if((green_cs_out > blue_cs_out) && (green_cs_out > red_cs_out)) filter_cs_out = 2'b11;
			else if(red_cs_out > blue_cs_out) filter_cs_out = 2'b00;
			else filter_cs_out = 2'b01; 
			
			if(node == 0) filter_cs_out = 2'b10;
			
			case (filter_cs_out)
				2'b11: begin
					if(green_cs_out >= 14 && green_cs_out <= 20) color <= 2;
				end
				2'b00: begin
					if(red_cs_out >= 28 && red_cs_out <= 35) color <= 1;
				end
				2'b01: begin 
					if((red_cs_out >= 8 && red_cs_out <= 13) && (blue_cs_out >= 22 && blue_cs_out <= 30)) color <= 3;
				end
				2'b10: color <= 0;
			endcase
			filter <= GREEN_FILTER;
			clk_count <= 1;
		end
	endcase	
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
