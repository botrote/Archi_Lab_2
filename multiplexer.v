
module multiplexer (
	input [`WORD_SIZE-1:0] input1,
	input [`WORD_SIZE-1:0] input2,
	input control_signal,

	output [`WORD_SIZE-1:0] output
);

	if(control_signal == 0)
		assign output = input1;
	else
		assign output = input2;

endmodule


//FIN