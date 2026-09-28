module code(
	input cs_out,clk,
	output reg s0,s1,s2,s3,OE,
	output reg [5:0] clk_count,
	output reg [10:0] count
);
	
initial begin
	s0 = 1; s1 = 1; s2 = 1; s3 = 1; OE = 0; count = 0; clk_count = 0;
end

always @(posedge cs_out)begin
	count = count + 1;
	if(clk_count == 50) count = 0;
end	
always @(posedge clk)begin
	if(clk_count == 50) begin 
		clk_count = 0;
//		{s2,s3} = {s2,s3} + 1;
	end
	
	clk_count = clk_count + 1;
end
endmodule 
//
//module tcs3200_interface (
//    input wire clk,           // System clock
//    output reg S2,            // S2 output for TCS3200
//    output reg S3,            // S3 output for TCS3200
//    output wire S0,           // Fixed S0 for frequency scaling
//    output wire S1,           // Fixed S1 for frequency scaling
//    output wire OE,           // Output enable, always active
//    input wire frequency_in,  // Frequency signal from TCS3200
//    output reg [31:0] freq_count // Frequency count output
//);
//
//// Assign fixed values for S0, S1, and OE
//assign S0 = 1'b1; // Maximum scaling
//assign S1 = 1'b1; // Maximum scaling
//assign OE = 1'b0; // Output always enabled
//
//// Internal signals
//reg [31:0] counter;         // Counter to measure frequency
//reg [31:0] clk_div_counter; // Clock divider counter
//reg clk_div;                // Divided clock for frequency toggling
//reg [1:0] s2_s3;         // Single-bit input to control photodiode selection
//
//// Clock divider for toggling S3
//always @(posedge clk) begin
//	 s2_s3 = {S2,S3};
//    if (clk_div_counter == 32'd500000) begin
//        clk_div_counter <= 32'd0;
//        clk_div <= ~clk_div;
//    end else begin
//        clk_div_counter <= clk_div_counter + 1;
//    end
//end
//
//// Photodiode selection logic
//always @(posedge clk) begin
//    if (s2_s3 == 0) begin
//        S2 <= 1'b0; // Select Red or Green
//        S3 <= clk_div; // Toggle between Red and Green
//    end else begin
//        S2 <= 1'b1; // Select Blue or Clear
//        S3 <= clk_div; // Toggle between Blue and Clear
//    end
//end
//
//// Frequency measurement
//always @(posedge frequency_in or posedge clk_div) begin
//    if (clk_div) begin
//        freq_count <= counter; // Latch counter value
//        counter <= 32'd0;      // Reset counter
//    end else begin
//        counter <= counter + 1; // Increment counter on each frequency pulse
//    end
//end
//
//endmodule
