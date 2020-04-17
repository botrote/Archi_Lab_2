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
    wire [`WORD_SIZE - 1:0] shift_result;

    wire RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite; // control signals

    // MUX output
    wire [1:0] mux1_output;
    wire [`WORD_SIZE - 1:0] mux2_output;
    wire [`WORD_SIZE - 1:0] mux3_output;
    wire [`WORD_SIXE - 1:0] mux4_output;

    // register input, output
    wire [`WORD_SIZE - 1:0] read_data_1, read_data_2;
    wire [`WORD_SIZE - 1:0] write_data;

    // ALU input, output
    wire zero;
    wire ALU_result;

    reg [`WORD_SIZE - 1:0] pc = 16'h0;
    wire [`WORD_SIZE - 1:0] pc_4;
    wire [`WORD_SIZE - 1:0] other_pc;
    assign pc_4 = pc + 16'h4;

    assign opcode = data[15:12];
    assign rs = data[11:10];
    assign rt = data[9:8];
    assign rd = data[7:6];
    assign func = data[5:0];
    assign imm = data[7:0];
    assign target_address = data[11:0];

    control_unit control_unit1(opcode, func, RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);

    sign_extender sign_extender1(imm, extended_imm);
    shift shift_left_2(extended_imm, shift_result);

    adder adder2(pc_4, shift_result, other_pc); // PC = PC + imm

    multiplexer mux1(rd, rt, RegDst, mux1_output); // register input MUX
    multiplexer mux2(read_data_2, extended_imm, ALUSrc, mux2_output); // ALU input MUX

    wire mux3_control_signal;
    assign mux3_control_signal = Branch & zero;
    multiplexer mux3(pc_4, other_pc, mux3_control_signal, mux3_output); // PC + 4 MUX
    multiplexer mux4(mux3_output, ALU_result, Jump, mux4_output); // other PC MUX

    register_file register(rs, rt, write_data, mux1_output, RegWrite, clk, reset_n, read_data_1, read_data_2);

    alu alu1(ALUOp, read_data_1, mux2_output, zero, ALU_result);

    initial begin
        readM = 1;
        writeM = 0;
    end

    always @(inputReady) begin
        writeM = 1;
        data = ALU_result;
    end
    always @(ackOutput) begin
        readM = 1;
        writeM = 0;
    end


    always @(posedge clk or posedge reset_n)
    begin
        if(reset_n) begin
            pc <= 0;
        end
        else begin
            pc <= mux4_output;
        end

        address <= pc;
    end

endmodule
