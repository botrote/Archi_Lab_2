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

    wire [`WORD_SIZE - 1:0] extended_imm;

    wire RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite; // control signals

    // MUX output
    wire mux1_output;
    wire mux2_output;
    wire mux3_output;
    wire mux4_output;

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

    pc pc(clk, reset_n, );

    control_unit control_unit(opcode, func, RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);

    sign_extender(imm, extended_imm);

    adder adder1(pc, 16'd4); // PC = PC + 4
    adder adder2(pc, );

    multiplexer mux1(); // register input MUX
    multiplexer mux2(read_data_2, extended_imm, ALUSrc, mux2_output); // ALU input MUX
    multiplexer mux3(); // PC + 4 MUX
    multiplexer mux4(); // other PC MUX
    //multiplexer mux5(ALU_result, ); // data memory MUX

    register_file register(rs, rt, write_data, rd, RegWrite, clk, reset_n, read_data_1, read_data_2);

    alu alu(ALUOp, read_data_1, read_data_2, imm, zero, ALU_result);

    always @(posedge clk or posedge reset_n)
    begin
        if(reset_n) begin
            pc <= 0;
        end
        else if(opcode == `JMP_OP) begin
            pc <= target_address;
        end
        else if(opcode == `BNE_OP || opcode == `BEQ_OP || opcode == `BGZ_OP || opcode == `BLZ_OP) begin
            pc <= pc + 1 + $signed(imm);
        end
        else begin
            pc <= pc + 1;
        end
    end

endmodule
