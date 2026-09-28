
// data_mem.v - data memory

module data_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 64) (
    input       clk, wr_en,
    input [2:0] funct3,
    input       [ADDR_WIDTH-1:0] wr_addr, wr_data,
    output  reg    [DATA_WIDTH-1:0] rd_data_mem
);

// array of 64 32-bit words or data
reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];
wire [ADDR_WIDTH-1:0] word_addr = wr_addr[DATA_WIDTH-1:2] % 64;

//combinational read logic
//word aligned memory access
//assign  reg    [DATA_WIDTH-1:0] rd_data_mem= data_ram[wr_addr[DATA_WIDTH-1:2]%64];

// synchronous write logic
always @(posedge clk) begin                          // this always block is run at every positive rising edge of the clock
    if (wr_en) begin                                             // we arent concerned about the opcode
                                                                 // funcs in this sb, sw etc since write enable is made one
        case(funct3)                                             // only when the particular opcode is present
        3'b000: begin
            case(wr_addr[1:0])
                2'b00: data_ram[word_addr][7:0] = wr_data[7:0];        // all this to do SB
                2'b01: data_ram[word_addr][15:8] = wr_data[7:0];       // only particular byte from 4 byte word is stored
                2'b10: data_ram[word_addr][23:16] = wr_data[7:0];
                2'b11: data_ram[word_addr][31:24] = wr_data[7:0];
				endcase
        end
        3'b010: data_ram[word_addr] <= wr_data;                         // stores whole word
        3'b001: data_ram[word_addr][15:0] <= wr_data[15:0];              // stores half word

    endcase
                
end
end 
always @(*) begin          // this block is run everytime there is made any change to any of the 
    case (funct3)          // parameters that this block depends on
			3'b000:begin                 //lb
				case(wr_addr[1:0])
                2'b00: rd_data_mem = {{24{data_ram[word_addr][7]}},data_ram[word_addr][7:0]};     
                2'b01: rd_data_mem = {{24{data_ram[word_addr][15]}},data_ram[word_addr][15:8]};      
                2'b10: rd_data_mem = {{24{data_ram[word_addr][23]}},data_ram[word_addr][23:16]};
                2'b11: rd_data_mem = {{24{data_ram[word_addr][31]}},data_ram[word_addr][31:24]};
            endcase
			end
			3'b001:begin                 //lh
            case(wr_addr[1])
                1'b0: rd_data_mem = {{16{data_ram[word_addr][15]}},data_ram[word_addr][15:0]};     
                1'b1: rd_data_mem = {{16{data_ram[word_addr][31]}},data_ram[word_addr][31:16]}; 
            endcase
			end
        
			3'b100: begin 
            case(wr_addr[1:0])    //lbu
                2'b00: rd_data_mem = {{24'b0,data_ram[word_addr][7:0]}};     
                2'b01: rd_data_mem = {{24'b0,data_ram[word_addr][15:8]}};      
                2'b10: rd_data_mem = {{24'b0,data_ram[word_addr][23:16]}};
                2'b11: rd_data_mem = {{24'b0,data_ram[word_addr][31:24]}};
        
				endcase
         end 
        
			3'b101: begin 
          case(wr_addr[1])    //lhu
                1'b0: rd_data_mem = {{16'b0,data_ram[word_addr][15:0]}};     
                1'b1: rd_data_mem = {{16'b0,data_ram[word_addr][31:16]}}; 
				endcase
       end 
       
			3'b010: rd_data_mem = data_ram[word_addr]; //lw syntax
endcase                       

end

endmodule

