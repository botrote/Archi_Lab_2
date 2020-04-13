
module alu (
	ALUOp,
	data_1,
	data_2,
	imm,

	zero,
	ALU_result
);

    input [2:0] ALUOp;
    input [`WORD_SIZE-1:0] data_1;
    input [`WORD_SIZE-1:0] data_2;
    input [11:0] imm;

    output zero;
    output [`WORD_SIZE-1:0] ALU_result;

	reg zero;
	reg [`WORD_SIZE - 1:0] ALU_result;

	always @ (*) begin
		zero = 0;
		ALU_result = 0;

		case (ALUOp)
			FUNC_ADD : begin
				ALU_result = data_1 + data_2;
				if(ALU_result == 0)
					zero = 1;
				else
					zero = 0;
			end

			FUNC_SUB : begin
				ALU_result = data_1 - data_2; // Not Sure
				if(ALU_result == 0)
					zero = 1;
				else
					zero = 0;
			end

			FUNC_AND : begin
				ALU_result = data_1 & data_2;
				if(ALU_result == 0)
					zero = 1;
				else
					zero = 0;
			end

			FUNC_ORR : begin
				ALU_result = data_1 | data_2;
				if(ALU_result == 0)
					zero = 1;
				else
					zero = 0;
			end

			FUNC_NOT : begin
				ALU_result = data_1 ^ data_2;
				if(ALU_result == 0)
					zero = 1;
				else
					zero = 0;
			end

			FUNC_TCP : begin
				ALU_result = ~(data_1) + 1;
				if(ALU_result == 0)
					zero = 1;
				else
					zero = 0;
			end

			FUNC_SHL : begin
				ALU_result = data_1 << imm;
				if(ALU_result == 0)
					zero = 1;
				else
					zero = 0;
			end

			FUNC_SHR : begin
				ALU_result = data_1 >> imm;
				if(ALU_result == 0)
					zero = 1;
				else
					zero = 0;
			end

endmodule
