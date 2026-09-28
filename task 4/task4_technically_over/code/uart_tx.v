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

Baudrate: 115200 

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
    input tx_start,
    input [7:0] data,
    output reg tx, tx_done
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

localparam STARTBIT  = 2'b00,
			  DATABIT   = 2'b01,
			  PARITYBIT = 2'b10,
			  ENDBIT	   = 2'b11;
reg [1:0]state;
integer i;
reg [3:0] count;
reg [5:0] clk_per_bit;

initial begin
    tx = 1; tx_done = 0; state = 0; clk_per_bit = 0; count = 0;
end

always @(posedge clk_3125)begin
	case(state)
		STARTBIT: begin
			tx_done <= 0;
			if(tx_start == 1)begin
				clk_per_bit <= clk_per_bit + 1;
				tx <= 0;
			end
			if(clk_per_bit != 0) begin 
				clk_per_bit <= clk_per_bit + 1; 
			end
			if(clk_per_bit == 26) begin
				clk_per_bit <= 0;
				state <= DATABIT; 
			end
		end
		
		DATABIT: begin
			clk_per_bit <= clk_per_bit + 1;
			if(clk_per_bit == 0)begin
				tx <= data[7-count];
			end
			if(clk_per_bit == 26) begin
				count <= count + 1;
				clk_per_bit <= 0;
				if(count == 7) begin
					state <= PARITYBIT;
					count <= 0;
				end
			end
		end
		
		PARITYBIT: begin
			clk_per_bit <= clk_per_bit + 1;
			
			if(clk_per_bit == 0) tx <= ^data;
			if(clk_per_bit == 26)begin
				clk_per_bit <= 0;
				state <= ENDBIT;
			end
		end
		
		ENDBIT: begin
			clk_per_bit <= clk_per_bit + 1;
			if(clk_per_bit == 0) begin 
				tx <= 1;
			end
			
			if(clk_per_bit == 26) begin
				tx_done <= 1;
				clk_per_bit <= 0;
				state <= STARTBIT;
			end
		end
	endcase
end


//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule

