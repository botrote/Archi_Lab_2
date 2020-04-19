module immediate_generator(
	imm,
	target_address,
	
	extended_target,
	extended_imm1,
	extended_imm2
);

	input [7:0] imm;
	input [11:0] target_address;

	output reg [`WORD_SIZE - 1:0] extended_target, extended_imm1, extended_imm2;

	integer i;
	always @(*)
	begin
		extended_target = (extended_target | target_address) << 8;
		for(i = 0; i < 8; i = i + 1) begin
			if(extended_target[15] == 1)
			    extended_target = (extended_target >> 1) + 16'h8000;
            else
                extended_target = extended_target >> 1;
		end

		extended_imm1 = (extended_imm1 | imm) << 8;
		for(i = 0; i < 8; i = i + 1) begin
			if(extended_imm1[15] == 1)
				extended_imm1 = (extended_imm1 >> 1) + 16'h8000;
            else
                extended_imm1 = extended_imm1 >> 1;
		end

		extended_imm2 = (extended_imm2 | imm) << 8;		
	end

endmodule