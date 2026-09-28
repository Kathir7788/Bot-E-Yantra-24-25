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

Baudrate: 115200 

Input:  clk_3125 	- 3125 KHz clock
        rx      	- UART Receiver

Output: rx_msg 		- received input message of 8-bit width
		  rx_parity 	- received parity bit
        rx_complete 	- successful uart packet processed signal
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
localparam [1:0] STARTBIT  = 2'b00,
					  DATABIT   = 2'b01,
					  PARITYBIT = 2'b10,
					  ENDBIT    = 2'b11;
reg temp_rx_parity,rx_parity_temp;
reg [1:0] state;
reg [3:0] count;
reg [5:0] clk_per_bit;
reg [7:0] temp_rx_msg;

integer i;

initial begin
    rx_msg = 0; rx_parity = 0; rx_complete = 0; state = STARTBIT; count = 0; clk_per_bit = 0; count = 0; temp_rx_msg = 0; rx_parity_temp = 0; temp_rx_parity = 0;
end

always @(posedge clk_3125)begin
	case(state)
		STARTBIT:begin		
			if(clk_per_bit == 2) rx_complete <= 0;
			if(rx == 0) clk_per_bit <= clk_per_bit + 1;
			if(clk_per_bit == 26) begin 
				state <= DATABIT;
				clk_per_bit <= 0;
			end
		end
		
		DATABIT:begin
			clk_per_bit <= clk_per_bit + 1;
			if(clk_per_bit == 10) begin
				count <= count + 1;
				temp_rx_msg <= temp_rx_msg + (rx << (7-count));
			end
			
			if(clk_per_bit == 26) clk_per_bit <= 0;
			
			if(count == 8 && clk_per_bit == 0) begin
				count <= 0; 
				state = PARITYBIT;
			end
		end
		
		PARITYBIT:begin
			clk_per_bit <= clk_per_bit + 1;
			if(clk_per_bit == 10) begin
				rx_parity_temp <= rx;
				temp_rx_parity = 0;
				temp_rx_parity = ^temp_rx_msg;
			end
			if(clk_per_bit == 26)begin
				clk_per_bit <= 2;
				state <= ENDBIT;
			end
		end
		
		ENDBIT:begin
			clk_per_bit <= clk_per_bit + 1;
			if(clk_per_bit == 28) clk_per_bit <= 0;
			
			if(clk_per_bit == 1)begin
				temp_rx_msg <= 0; 
				rx_parity = rx_parity_temp;
				rx_complete <= 1;
				if(rx_parity_temp == temp_rx_parity) rx_msg = temp_rx_msg;
				else  rx_msg = 8'b00111111; 
				
				state <= STARTBIT;
			end
		end
	endcase
end 

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule
