/*
# Team ID:          3699
# Theme:            EcoMender Bot
# Author List:      NISHANTH, HARIKARAN, ADITHIYA, KATHIR
# Filename:         pwm_generator
# File Description: entire controls are done 
*/

// EcoMender Bot : Task 1A : PWM Generator
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will scale down the 1MHz Clock Frequency to 500Hz and perform Pulse Width Modulation on it.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//PWM Generator
//Inputs : clk_1MHz, pulse_width
//Output : clk_500Hz, pwm_signal

module pwm_generator(
    input clk_1MHz,
    input [3:0] pulse_width,
    output reg clk_500Hz, pwm_signal
);

initial begin
    clk_500Hz = 1; pwm_signal = 1;
end

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

/*
Add your logic here
*/

reg [10:0] counter= 0;
always @(posedge clk_1MHz) begin
	if (counter < 2000) counter <= counter + 1;
	else begin 
		counter <= 1;
		clk_500Hz <= ~clk_500Hz;
	end
	
	if (counter == 1000) clk_500Hz <= ~clk_500Hz;
	if(counter < pulse_width*100 || counter == 2000 || counter == 1) pwm_signal <=1;
	else pwm_signal <= 0;
	
	
//	$display("counter = %d, PWM_signal = %d, pulse_width = %d",counter,pwm_signal,pulse_width*100);
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule
