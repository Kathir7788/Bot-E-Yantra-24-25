/*
# Team ID:          3699
# Theme:            EcoMender Bot
# Author List:      NISHANTH, HARIKARAN, ADITHIYA, KATHIR
# Filename:         pwm_gen_led
# File Description: entire controls are done 
# Global variables: 
	clk_1MHz: 1MHz clock signal
	pulse_width: Ton time for pwm_signal
*/

module pwm_gen_led(
    input clk_1MHz,
    input [3:0] pulse_width,
    output reg pwm_signal
);

reg [13:0] counter;

initial begin
   pwm_signal = 1;
	counter = 0;
end

always @(posedge clk_1MHz) begin
	if (counter < 16383) counter <= counter + 1;
	else counter <= 0;
	
	if(counter < 2000) pwm_signal <=1;//pulse_width*8
	else pwm_signal <= 0;
end

endmodule
