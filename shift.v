`include "opcodes.v"

module shift_left_2 (
	input [`WORD_SIZE-1:0] shiftInput,

	output [`WORD_SIZE-1:0] shiftResult
);
	
	assign shiftResult = shiftInput << 2;

endmodule


//FIN
