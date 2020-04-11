
module sign_extender (
	input [7:0] imm,

	output [`WORD_SIZE-1:0] extended_imm
);
	
	assign extended_imm = {{`WORD_SIZE{imm[7]}}, imm};

endmodule


//FIN