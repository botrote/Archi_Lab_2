/*
	Adder for Updating PC
*/
`include "opcodes.v" 

module adder (
	input [`WORD_SIZE-1:0] input1,
	input [`WORD_SIZE-1:0] input2,

	output [`WORD_SIZE-1:0] ouput1
);

	assign output1 = input1 + input2;

endmodule


//FIN