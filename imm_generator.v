`include "opcodes.v"

module imm_generator(
	imm,

	processed_imm
);
	input [7:0] imm;

	output reg [`WORD_SIZE - 1:0] processed_imm;

	integer i;
	always @(*) begin
		processed_imm = 16'h0000;
		processed_imm = (processed_imm | imm);
		processed_imm = processed_imm << 8;

		for(i = 0; i< 8; i = i + 1) begin
			processed_imm = processed_imm >> 1;

			if(processed_imm[15] == 1)
				processed_imm = processed_imm + 16'h8000;
		end
	end

endmodule