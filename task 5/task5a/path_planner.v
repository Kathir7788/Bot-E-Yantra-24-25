module path_planner(
	input clk_3125,
	input MemWrite,
	input reset,
	input [31:0] DataAdr,
	input [31:0] WriteData,
	input en_path,
	output reg [7:0] PATH,
	output reg cpu_done
);

integer i,j;
reg [7:0] PATH_PLANNED[0:15];

initial begin
   i = 1;
	cpu_done = 0;
	PATH_PLANNED[0] = 1;
	PATH_PLANNED[1] = 2;
	PATH_PLANNED[2] = 3;
	PATH_PLANNED[3] = 4;
	PATH_PLANNED[4] = 5;
//	cpu_done = 1;
end

always @(negedge clk_3125) begin
//	if(MemWrite && !reset && cpu_done == 0) begin
//		if (DataAdr === 32'h02000008) begin
//			PATH_PLANNED[i] = 5;
//			i = i + 1'b1;
//		end
//		if (DataAdr === 32'h0200000c & WriteData === 32'h1) begin
//			cpu_done <= WriteData;
//		end
//	end
	
	if(en_path && cpu_done) begin
		if(j<6) begin
			PATH = PATH_PLANNED[j];
			j =j+1;
		end
	end
end

endmodule
