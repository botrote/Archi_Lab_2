/*
	Adder for Updating PC
*/

module adder (
	input [`WORD_SIZE-1:0] input1,
	input [`WORD_SIZE-1:0] input2,

	output [`WORD_SIZE-1:0] ouput
);

	assign output = input1 + input2;

endmodule


//FIN