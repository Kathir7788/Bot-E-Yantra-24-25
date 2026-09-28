module buffer(
	input clk_3125, rx_complete,
	input [7:0] rx_data,
	input started,
	input [1:0] color,
	input [2:0] node,
	output reg start_run,tx_start,
	output reg [0:7] tx_data
);
integer i,j;
reg [7:0] data_buffer[0:5];
reg [7:0] NODE[0:4];
reg [7:0] SLM[0:3];
reg [7:0] IM_AS_IS[0:5]; //red_discription ,green_discription ,blue_discription
reg [7:0] FSU[0:2];

reg [1:0] en;
reg [2:0] pre_node,pre_color;
reg [1:0] lap_count;
reg [8:0] count;
reg [7:0] tx_node;

initial begin
	start_run = 0; en = 0; count = 0; pre_node = 0; lap_count = 0; pre_color = 0; 
	NODE[0] = "N";//8'b01110010; //N
	NODE[1] = "O";//8'b11110010; //O
	NODE[2] = "D";//8'b00100010; //D
	NODE[3] = "E";//8'b10100010; //E
	
	SLM[0] = "S";//8'b11001010; //S
	SLM[1] = "L";//8'b00110010; //L
	SLM[2] = "M";//8'b10110010; //M
	
	IM_AS_IS[0] = "I";//8'b10010010; // I
	IM_AS_IS[1] = "M";//8'b10110010; // M
	IM_AS_IS[2] = "A";//8'b10000010; // A
	IM_AS_IS[3] = "S";//8'b11001010; // S
	IM_AS_IS[4] = "I";//8'b10010010; // I
	IM_AS_IS[5] = "S";//8'b11001010; // S
	
	FSU[0] = "F";//8'b01100010; //F
	FSU[1] = "S";//8'b11001010; //S
	FSU[2] = "U";//8'b10101010; //U
	
end

always @(negedge clk_3125) begin
	if(rx_complete) begin
		data_buffer[i] = {rx_data[0],rx_data[1],rx_data[2],rx_data[3],rx_data[4],rx_data[5],rx_data[6],rx_data[7]};
		i = i + 1;
	end 

	if(i == 5) i = 0;
	
	if({data_buffer[0], data_buffer[1], data_buffer[2], data_buffer[3], data_buffer[4]} == "START") start_run = 1;
	
	if(started) begin 
		for(i = 0; i<5 ; i = i + 1) if(data_buffer[i] != 0) data_buffer[i] = 0;
		start_run = 0;
	end
	
	//Node
	case(en)
		2'b00: begin
			if(pre_node != node) begin
				en <= 1;
				pre_node <= node;
				j <= 0;
				if (node == 0) lap_count = lap_count + 1;
				tx_node = (node+7*lap_count)%10 + 8'b00110000;
			end else if(pre_color != color)begin
				if(color != 0)begin
					en <= 2;
					pre_color = color;
					j <= 0;
				end
			end else begin
				tx_data <= {rx_data[0],rx_data[1],rx_data[2],rx_data[3],rx_data[4],rx_data[5],rx_data[6],rx_data[7]};
				tx_start <= rx_complete;
			end
			count <= 1;
		end
		
		2'b01:begin
			if(count == 297) begin
				if(j < 4) begin
					tx_data <= NODE[j];	
					tx_start <= 1;
					j <= j + 1;
					count <= 1;
				end else if(j == 4 && node+7*lap_count > 9) begin
					tx_data <= 8'b00110001;	
					tx_start <= 1;
					j <= j + 1;
					count <= 1;
				end else if(j == 4 && node+7*lap_count < 10) begin
					tx_data <= tx_node;//{tx_node[0],tx_node[1],tx_node[2],tx_node[3],tx_node[4],tx_node[5],tx_node[6],tx_node[7]};	
					tx_start <= 1;
					j <= j + 1;
					count <= 1;
				end else if(j == 5 && node+7*lap_count > 9) begin
					tx_data <= tx_node;//{tx_node[0],tx_node[1],tx_node[2],tx_node[3],tx_node[4],tx_node[5],tx_node[6],tx_node[7]};	
					tx_start <= 1;
					j <= j + 1;
					count <= 1;
				end else en <= 0;
			end
			
			count <= count + 1; 
			if(count == 2) tx_start <= 0;
		end
		
		2'b10: begin
			if(count == 297) begin
				if(j < 3)begin
					tx_data <= SLM[j];	
					tx_start <= 1;
					j <= j + 1;
					count <= 1;
				end else if(j == 3 || j == 8 || j == 11)begin
					tx_data <= 8'b00101101;//8'b10110100;	
					tx_start <= 1;
					j <= j + 1;
					count <= 1;
				end else if(j > 3 && j < 7) begin
					tx_data <= FSU[j-4];	
					tx_start <= 1;
					j <= j + 1;
					count <= 1;
				end else if(j == 7)begin
					if(color == 1) tx_data <= 8'b00110010;//8'b01001100;//red
					else if(color == 2) tx_data <= 8'b00110001;//8'b10001100;// blue
					else if(color == 3) tx_data <= 8'b00110011;//8'b11001100;//green	
					tx_start <= 1;
					j <= j + 1;
					count <= 1;
				end else if(j > 8 && j < 11) begin
					tx_data <= IM_AS_IS[j-9+2*(color-1)];	
					tx_start <= 1;
					j <= j + 1;
					count <= 1;
				end else if(j == 12)begin
					tx_data <= "#";//8'b11000100;	
					tx_start <= 1;
					j <= j + 1;
					count <= 1;
				end else en <= 0;
			end
			
			count <= count + 1; 
			if(count == 2) tx_start <= 0;
		end
	endcase
end
endmodule 