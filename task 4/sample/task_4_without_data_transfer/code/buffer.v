module buffer(
	input clk, rx_complete,
	input [7:0] rx_data,
	input started,
	input [1:0] color,
	input [2:0] node,
	output reg start_run,tx_start,
	output reg [7:0] tx_data
);
integer i,j;
reg [7:0] data_buffer[0:5];
reg [7:0] NODE[0:4]; 
reg en;
reg [2:0] pre_node;
reg [8:0] count;
reg [7:0] tx_node;

initial begin
	start_run = 0; en = 0; count = 0; pre_node = 0; 
	NODE[0] = 8'b01110010; //N
	NODE[1] = 8'b11110010; //O
	NODE[2] = 8'b00100010; //D
	NODE[3] = 8'b10100010; //E
	NODE[4] = 8'b10110100; //-
end

always @(negedge clk) begin
	if(rx_complete) begin
		data_buffer[i] = {rx_data[0],rx_data[1],rx_data[2],rx_data[3],rx_data[4],rx_data[5],rx_data[6],rx_data[7]};
		i = i + 1;
	end 

	if(i == 5) i = 0;
	
	if(data_buffer[0] == 8'b01110011 && data_buffer[1] == 8'b01110100 && data_buffer[2] == 8'b01100001 && data_buffer[3] == 8'b01110010 && data_buffer[4] == 8'b01110100 ) start_run = 1;
	
	if(started) begin 
		for(i = 0; i<5 ; i = i + 1) if(data_buffer[i] != 0) data_buffer[i] = 0;
		start_run = 0;
	end
	

	if(en) begin
		if(count == 297) begin
			if(j < 5) begin
				tx_data <= NODE[j];	
				tx_start <= 1;
				j <= j + 1;
				count <= 1;
			end else if(j == 5)begin
				tx_data <= 8'b00001100;	
				tx_start <= 1;
				j <= j + 1;
				count <= 1;
			end else if(j == 6) begin
				tx_data <= {tx_node[0],tx_node[1],tx_node[2],tx_node[3],tx_node[4],tx_node[5],tx_node[6],tx_node[7]};	
				tx_start <= 1;
				j <= j + 1;
				count <= 1;
			end
			if(j == 7) en = 0;
		end
		count <= count + 1; 
		if(count == 2) tx_start <= 0;
	end else begin
		if(pre_node != node) begin
			en <= 1;
			pre_node <= node;
			j <= 0;
			tx_node = node + 8'b00110000;
		end else begin
			tx_data <= rx_data;
			tx_start <= rx_complete;
		end
		count <= 1;
	end
end
endmodule 