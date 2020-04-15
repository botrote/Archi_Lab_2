`include "opcodes.v" 	   

module cpu (readM, writeM, address, data, ackOutput, inputReady, reset_n, clk);
    output readM;
    output writeM;
    output [`WORD_SIZE-1:0] address;
    inout [`WORD_SIZE-1:0] data;
    input ackOutput;
    input inputReady;
    input reset_n;
    input clk;

    // instruction elements
    wire [3:0] opcode;
    wire [1:0] rs;
    wire [1:0] rt;
    wire [1:0] rd;
    wire [5:0] func;
    wire [7:0] imm;
    wire [11:0] target;

    wire RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite; // control signals

    // register input, output
    wire [`WORD_SIZE - 1:0] read_data_1, read_data_2;
    wire [`WORD_SIZE - 1:0] write_data;


    // ALU input, output
    wire zero;
    wire ALU_result;

    reg [`WORD_SIZE - 1:0] pc = 16'h0;

    assign opcode = data[15:12];
    assign rs = data[11:10];
    assign rt = data[9:8];
    assign rd = data[7:6];
    assign func = data[5:0];
    assign imm = data[7:0];
    assign target_address = data[11:0];

    control_unit control_unit(opcode, func, RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);

    register_file register(rs, rt, write_data, rd, RegWrite, clk, reset_n, read_data_1, read_data_2);

    alu alu(ALUOp, read_data_1, read_data_2, imm, zero, ALU_result);

    always @(posedge clk)
    begin
        if(opcode == `JMP_OP) begin
            pc = target_address;
        end
        else if(opcode == `BNE_OP || opcode == `BEQ_OP || opcode == `BGZ_OP || opcode == `BLZ_OP) begin
            pc = pc + 1 + $signed(imm);
        end
        else begin
            pc = pc + 1;
        end
    end

endmodule
