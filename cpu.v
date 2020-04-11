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

    
endmodule

module alu ();

endmodule


module register_file (
    clk,

);
    input clk;

    always @ () begin
        if()

endmodule


module control_unit (
    opcode,
    func
);
    input [4:0] opcode;
    input [6:0] func;

    output [4:0] ALUOp // ???
    output RegWrite

    reg [4:0] ALUOp
    reg RegWrite

    always @(*)

        case (opcode)
        4b'1111 : begin // R-format
            case (func)
            6b'000000 : begin // 
                ALUOp = 1

endmodule
