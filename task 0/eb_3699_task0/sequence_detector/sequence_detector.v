// Verilog code for Sequence Detector
    // Define Sequence Detector module
    module sequence_detector (
        input clock,
        input [3:0] number, // Define input ports clock, number
        output reg pattern // Define output port pattern
    );


	 //////////////////////////////////////////////
    // Define your State Machine Parameters Here
    parameter ST_ONE = 2'b00, ST_ZERO = 2'b01, ST_NINE = 2'b10, ST_FOUR = 2'b11;
	 //////////////////////////////////////////////

    // defining 2-bit register
    reg [1:0] state = ST_ONE;

    initial begin // define initial state output register
        pattern = 0;
    end

    always @(posedge clock) begin
        pattern = 0;
        case (state)
				ST_ONE: 
					if (number == 1)
						state = ST_ZERO;
					else 
						state = ST_ONE;
				ST_ZERO: 
					if (number == 0)
						state = ST_NINE;
					else 
						state = ST_ONE;
				ST_NINE: 
					if (number == 9)
						state = ST_FOUR;
					else 
						state = ST_ONE;
				ST_FOUR:
					state = ST_ONE;
        endcase
    end

    endmodule