// EcoMender Bot : Task 2A - UART Transmitter
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to generate UART Tx data packet to transmit the messages based on the input data.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Transmitter

Input:  clk_3125 - 3125 KHz clock
        parity_type - even(0)/odd(1) parity type
        tx_start - signal to start the communication.
        data    - 8-bit data line to transmit

Output: tx      - UART Transmission Line
        tx_done - message transmitted flag
*/

// module declaration
module uart_tx(
    input clk_3125,
    input parity_type,tx_start,
    input [7:0] data,
    output reg tx, tx_done
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

initial begin
    tx = 1;
    tx_done = 0;
end

reg [3:0] clk_per_bit = 0;
reg [3:0] place = 10;
reg parity = 0 ;
reg [1:0] STATE = 0;
integer i;

// Add your code here...
always @(posedge clk_3125) begin
	if(!tx_start) begin
		clk_per_bit <= clk_per_bit + 1;
		
		if(!place && clk_per_bit >= 13)begin 
				tx_done <= ~tx_done;
			end
		if(clk_per_bit == 14) begin
			case(place)
				4'b0   : tx <= 1;
				4'b01  : tx <= 1;
				4'b10  : tx <= parity;
				default: tx <= data[place-3];
			endcase
			place <= place -1;
			clk_per_bit <= 1;
		end
	end else begin
		tx <= 0;
		place <= 10;
		clk_per_bit <= 1;
		parity = 0;
		for(i = 0;i < 8;i = i + 1) begin
			parity = parity ^ data[i];
			$display("parity = %0b data[%0d] = %0b",parity,i,data[i]);
		end
	end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule 