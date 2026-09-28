/*
# Team ID:          3699
# Theme:            EcoMender Bot
# Author List:      NISHANTH, HARIKARAN, ADITHIYA, KATHIR
# Filename:         cpu_starter
# File Description: entire controls are done 
# Global variables: 
	clk_3125: 3.125 MHz clock signal
	cpu_en: triggers CPU to generate path_planned array
	SP: Start Point of path_planned
	EP: End Point of path_planned
	reset: to reset CPU
*/

module cpu_starter(
    input clk_3125,
    input cpu_en,
    input [5:0] SP,
    input [5:0] EP,
    output reg reset,
    output reg Ext_MemWrite,
    output reg [31:0] Ext_WriteData,
    output reg [31:0] Ext_DataAdr
);
integer count;
reg en;
 
initial begin
  en = 0;
  count = 0;
  reset = 1;
end

always @(posedge clk_3125) begin
	if (cpu_en == 1 || en == 1 ) begin
		en = 1;
		count = count + 1;

		case (count)
			 1: begin
				  reset = 1; 
				  Ext_MemWrite = 1; 
				  Ext_WriteData = SP; 
				  Ext_DataAdr = 32'h02000000;
			 end
			 2: begin
				  Ext_MemWrite = 0; 
				  Ext_WriteData = 32'h0; 
				  Ext_DataAdr = 32'h0;
			 end
			 3: begin
				  Ext_MemWrite = 1; 
				  Ext_WriteData = EP; 
				  Ext_DataAdr = 32'h02000004;
			 end
			 4: begin
				  Ext_MemWrite = 0; 
				  Ext_WriteData = 32'h0; 
				  Ext_DataAdr = 32'h0;
			 end
			 5: begin
				  Ext_MemWrite = 1; 
				  Ext_WriteData = 32'h0; 
				  Ext_DataAdr = 32'h02000008;
			 end
			 6: begin
				  Ext_MemWrite = 0; 
				  Ext_WriteData = 32'h0; 
				  Ext_DataAdr = 32'h0;
			 end
			 7: begin
				  Ext_MemWrite = 1; 
				  Ext_WriteData = 32'h0; 
				  Ext_DataAdr = 32'h0200000c;
			 end
			 8: begin
				  Ext_MemWrite = 0; 
				  Ext_WriteData = 32'h0; 
				  Ext_DataAdr = 32'h0;
			 end
			 9: begin
				  reset = 0;
				  Ext_MemWrite = 0; 
				  Ext_WriteData = 32'h0; 
				  Ext_DataAdr = 32'h0;
				  en = 0;
				  count = 0;
			 end
		endcase
	end
end
endmodule
