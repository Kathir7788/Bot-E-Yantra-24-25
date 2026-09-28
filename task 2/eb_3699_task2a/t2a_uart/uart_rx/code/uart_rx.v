// EcoMender Bot : Task 2A - UART Receiver
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to receive UART Rx data packet from receiver line and then update the rx_msg and rx_complete data lines.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Receiver

Baudrate: 230400 

Input:  clk_3125 - 3125 KHz clock
        rx      - UART Receiver

Output: rx_msg - received input message of 8-bit width
        rx_parity - received parity bit
        rx_complete - successful uart packet processed signal
*/

// module declaration
module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

initial begin
    rx_msg = 0;
	 rx_parity = 0;
    rx_complete = 0;
end

// Add your code here....

reg [4:0]clk_per_bit = 0;
reg [3:0]count = 0;
reg [7:0] rx_msg_sample = 0; 
reg rx_parity_sample,rx_parity_sample1;
integer i;

always @(posedge clk_3125)begin
	clk_per_bit <= clk_per_bit + 1;
	rx_complete <= 0;

	
	if(clk_per_bit == 16)begin
		count <= count + 1;
		if(count >= 0 && count < 8) begin 
			rx_msg_sample <= rx_msg_sample + (rx << (7-count));
		end
				
		if(count == 8) begin
			rx_parity_sample1 = rx;
		end
		
		clk_per_bit <= 3;
	end
	
	if(count == 10 && clk_per_bit == 14)begin
		rx_msg_sample <= 0;
		count <= 0;
		rx_parity_sample = 0;
		
		for(i = 0 ;i < 8 ;i = i + 1)begin
			rx_parity_sample = rx_parity_sample ^ rx_msg_sample[7-i];
//			$display("temp_rxp = %0b temp_msg = %0b",rx_parity_sample,rx_msg_sample[7-i]);
		end
				
		if(rx_parity_sample1 == rx_parity_sample) rx_msg = rx_msg_sample;
		else rx_msg = 8'b00111111;
		
		rx_parity = rx_parity_sample1;
		rx_complete <= 1; 
		clk_per_bit <= 1;
	end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////


endmodule