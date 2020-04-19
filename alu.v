`include "opcodes.v"

module alu(
	func,
	data_1,
	data_2,

	ALU_result
);

	input [5:0] func;
	input [`WORD_SIZE - 1:0] data_1;
	input [`WORD_SIZE - 1:0] data_2;

	output reg [`WORD_SIZE - 1:0] ALU_result;

	//reg [`WORD_SIZE - 1:0] ALU_result_reg;

	always @(*) begin
		case(func)
			`INST_FUNC_ADD: begin
				$display("%h", ALU_result);
				$display("inside ALU %h %h", data_1, data_2);
				ALU_result = data_1 + data_2;
				$display("%h", ALU_result);
			end

			`INST_FUNC_SUB: begin 
				ALU_result = data_1 - data_2; 
			end
			
			`INST_FUNC_NOT: begin 
				ALU_result = ~data_1; 
			end
			
			`INST_FUNC_AND: begin 
				ALU_result = data_1 & data_2; 
			end

			`INST_FUNC_ORR: begin 
				ALU_result = data_1 | data_2; 
			end
			
			`INST_FUNC_TCP: begin 
				ALU_result = ~(data_1) + 1; 
			end
			
			`INST_FUNC_SHL: begin 
				ALU_result = data_1 << 1; 
			end
			
			`INST_FUNC_SHR: begin 
				ALU_result = data_1 >> 1; 
			end
		endcase
	end

	//assign ALU_result = ALU_result_reg;
endmodule
