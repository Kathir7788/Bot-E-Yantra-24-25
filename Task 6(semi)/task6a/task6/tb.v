`timescale 1 ns/1 ns

module tb;

reg clk, reset, Ext_MemWrite;
reg [31:0] Ext_WriteData, Ext_DataAdr;

wire [31:0] WriteData, DataAdr, ReadData, PC, Result;
wire MemWrite;

reg [4:0] SP = 0, EP = 0;

integer error_count = 0, i = 0;
integer fw = 0, fd = 0, num_values = 16;
reg [4:0] register_array [0:15];
integer value = 0;

integer data_1 = 0, data_2 = 0, data_3, cpu_data = 0;
reg flag = 0;

t1c_riscv_cpu uut (clk, reset, Ext_MemWrite, Ext_WriteData, Ext_DataAdr, MemWrite, WriteData, DataAdr, ReadData, PC, Result);

initial begin
    for (i = 0; i < 16; i = i + 1'b1) begin
        register_array[i] = 0;
    end
	 register_array[0] = 8;
	 register_array[1] = 6;
	 register_array[2] = 0;
	 register_array[3] = 1;
	 register_array[4] = 11;
end

always begin
    clk <= 1; # 5; clk <= 0; # 5;
end

// For path planning algorithm - path_planner.c
initial begin
    i = 0;
    SP = 8;
	 EP = 11;

    reset = 1;

    // write START_POINT variable in the memory address 02000000
    Ext_MemWrite = 1; Ext_WriteData = SP; Ext_DataAdr = 32'h02000000; #8;
    Ext_MemWrite = 0; Ext_WriteData = 00; Ext_DataAdr = 32'h0; #11;

    // write END_POINT in the memory address 02000004
    Ext_MemWrite = 1; Ext_WriteData = EP; Ext_DataAdr = 32'h02000004; #8;
    Ext_MemWrite = 0; Ext_WriteData = 00; Ext_DataAdr = 32'h0; #12;

    // write NODE_POINT as 00 in the memory address 02000008
    Ext_MemWrite = 1; Ext_WriteData = 00; Ext_DataAdr = 32'h02000008; #8;
    Ext_MemWrite = 0; Ext_WriteData = 00; Ext_DataAdr = 32'h0; #11;

    // write NODE_POINT as 00 in the memory address 0200000c
    Ext_MemWrite = 1; Ext_WriteData = 00; Ext_DataAdr = 32'h0200000c; #8;
    Ext_MemWrite = 0; Ext_WriteData = 00; Ext_DataAdr = 32'h0; #12;

    reset = 0;
    // External Memory Access Disabled
    Ext_MemWrite = 0; Ext_WriteData = 0; Ext_DataAdr = 0;
    i = 0;
end

always @(negedge clk) begin
    if(MemWrite && !reset) begin
        if (DataAdr === 32'h02000008) begin
            $display("Expected NODE POINT = %d, Actual NODE POINT = %d", register_array[i], WriteData);
            i = i + 1'b1;
        end
    end
end

endmodule

