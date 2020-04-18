`include "opcodes.v"

module alu(
	func,
	data_1,
	data_2,

	ALU_result
);

	input [2:0] func;
	input [`WORD_SIZE - 1:0] data_1;
	input [`WORD_SIZE - 1:0] data_2;

	output [`WORD-SIZE - 1:0] ALU_result;

	reg [`WORD_SIZE - 1:0] ALU_result;

	initial begin
		ALU_result = 0;
	end

	always @(*) begin
		case(func)
			`FUNC_ADD: begin
				ALU_result = data_1 + data_2;
			end

			`FUNC_SUB: begin 
				ALU_result = data_1 - data_2; 
			end
			
			`FUNC_NOT: begin 
				ALU_result = ~data_1; 
			end
			
			`FUNC_AND: begin 
				ALU_result = data_1 & data_2; 
			end

			`FUNC_ORR: begin 
				ALU_result = data_1 | data_2; 
			end
			
			`FUNC_TCP: begin 
				ALU_result = ~(data_1) + 1; 
			end
			
			`FUNC_SHL: begin 
				ALU_result = data_1 << 1; 
			end
			
			`FUNC_SHR: begin 
				ALU_result = data_1 >> 1; 
			end
		endcase

	end
endmodule