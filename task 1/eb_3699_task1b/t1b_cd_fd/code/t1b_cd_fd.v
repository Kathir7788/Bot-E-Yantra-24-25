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
    output reg [1:0] filter, color
);

// red   -> color = 1;
// green -> color = 2;
// blue  -> color = 3;

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

initial begin // editing this initial block is allowed
    filter = 3; color = 0;
end

/*
Add your logic here
*/
reg [8:0] clk_filter = 0;
reg [1:0] cycle_count = 0;
reg [5:0] cs_out_count = 0;
reg [1:0] sample_cs_out = 0;
reg [1:0] filter_cs_out;

always @(posedge cs_out) begin
	if(clk_filter == 250)	cs_out_count <= cs_out_count + 1;
	if(clk_filter == 500) begin
		if(sample_cs_out < cs_out_count/16)begin //finding which color have more frequancy
			sample_cs_out <= cs_out_count/16;
			filter_cs_out <= filter;
		end
		cs_out_count <= 0;
	end
	if(cycle_count == 3)	sample_cs_out <= 0;
end

always @(posedge clk_1MHz) begin
	if(clk_filter < 500 && cycle_count < 3) begin
		clk_filter <= clk_filter + 1;
	end else begin
		if(filter < 3) filter <= filter+1;
		else filter <= 0;
		clk_filter <= clk_filter + 1;
		cycle_count <= cycle_count + 1;
		clk_filter <= 1;
		if(cycle_count == 2) begin
			case(filter_cs_out) 
				2'b11:color = 2;
				2'b0:color = 1;
				2'b1:color = 3;
			endcase
		end
	end
	if(cycle_count == 3) begin
		if(filter < 3) filter <= filter+1;
		else filter <= 0;
		cycle_count <= 0;
	end
end
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
