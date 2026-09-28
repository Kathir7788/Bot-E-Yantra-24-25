module buffer(
	input clk, tx_complete,
	input [7:0] tx_data,
	input started,
	output reg start_run
);
integer i,j;
reg [7:0] data_buffer[0:10];

initial begin
	start_run = 0;
end

always @(posedge clk) begin
	if(tx_complete) begin
		data_buffer[i] = {tx_data[0],tx_data[1],tx_data[2],tx_data[3],tx_data[4],tx_data[5],tx_data[6],tx_data[7]};
		i = i + 1;
	end 

	if(i == 5) i = 0;
	
//	start_run = (data_buffer[0] == 8'b01110011 && data_buffer[1] == 8'b01110100 && data_buffer[2] == 8'b01100001 && data_buffer[3] == 8'b01110010 && data_buffer[4] == 8'b01110100);
	
	if(data_buffer[0] == 8'b01110011 && data_buffer[1] == 8'b01110100 && data_buffer[2] == 8'b01100001 && data_buffer[3] == 8'b01110010 && data_buffer[4] == 8'b01110100 ) start_run = 1;
	
	if(started) begin 
		for(i = 0; i<10 ; i = i + 1) if(data_buffer[i] != 0) data_buffer[i] = 0;
		start_run = 0;
	end
end
endmodule 