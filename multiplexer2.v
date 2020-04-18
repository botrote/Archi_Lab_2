`include "opcodes.v"

module multiplexer2 (
	input [1:0] input1,
	input [1:0] input2,
	input control_signal,

	output [1:0] output1
);


	assign output1 = ((control_signal == 0) ? input1 : input2);



endmodule


//FIN
