`include "opcodes.v"

module multiplexer (
	input [`WORD_SIZE-1:0] input1,
	input [`WORD_SIZE-1:0] input2,
	input control_signal,

	output [`WORD_SIZE-1:0] output1
);


	assign output1 = ((control_signal == 0) ? input1 : input2);



endmodule


//FIN