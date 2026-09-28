
// main_decoder.v - logic for main decoder

module main_decoder (
    input  [6:0] op,
    input  [2:0] funct3,
    input        Zero, ALUR31,
    output [1:0] ResultSrc,
    output       MemWrite, Branch, ALUSrc,
    output       RegWrite, Jump,Jalr,
    output [1:0] ImmSrc,
    output [1:0] ALUOp
);

reg [10:0] controls;
reg TakeBranch;

always @(*) begin
    TakeBranch = 0;
    casez (op[6:2])   //casez used to use the ? in the 7bit in some sitations like the lui and alui where there is only 1 bit diff
        // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_ALUOp_Jump_Jarl        //to imp branch we removed branch first??
        5'b00000: controls = 11'b1_00_1_0_01_00_0_0; // lw
        5'b01000: controls = 11'b0_01_1_1_00_00_0_0; // sw
        5'b01100: controls = 11'b1_xx_0_0_00_10_0_0; // R–type
        5'b11000:begin                               // branch taken 
            controls = 11'b0_10_0_0_00_01_0_0; // beq
            case (funct3)
                3'b000: TakeBranch = Zero;   //beq
                3'b001: TakeBranch = !Zero;  //bne
                3'b101: TakeBranch = !ALUR31;  //bge
                3'b100: TakeBranch = ALUR31;   //blt
                3'b110: TakeBranch = ALUR31; //bltu
                3'b111: TakeBranch = !ALUR31; //bgeu
            endcase

        end
        5'b00100: controls = 11'b1_00_1_0_00_10_0_0; // I–type ALU
        5'b11011: controls = 11'b1_11_0_0_10_00_1_0; // jal
        5'b11001: controls = 11'b1_00_1_1_10_00_0_1; // jalr
        5'b0?101: controls = 11'b1_xx_x_0_11_xx_0_0; //lui or auipc                   
        default:    controls = 11'bx_xx_x_x_xx_xx_x_x; // ???
    endcase
end
// sb, lb, lbu are made by modifying our data memory file importantly
assign Branch = TakeBranch;
assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUOp, Jump, Jalr} = controls;

endmodule

