`include "opcodes.v"
`timescale 1ns/100ps

module cpu (readM, writeM, address, data, ackOutput, inputReady, reset_n, clk);
	output readM;
	output writeM;
	output [`WORD_SIZE-1:0] address;
	inout [`WORD_SIZE-1:0] data;
	input ackOutput;
	input inputReady;
	input reset_n;
	input clk;

	// CPU output
	reg readM;
	reg writeM;
	reg [`WORD_SIZE -1:0] address;

    	reg [`WORD_SIZE - 1:0] pc;

	// instruction sub parts
	wire [3:0] opcode;
	wire [1:0] rs;
	wire [1:0] rt;
	wire [1:0] rd;
	wire [5:0] func;
	wire [7:0] imm;
	wire [11:0] target_address;

	assign opcode = data[15:12];
	assign rs = data[11:10];
	assign rt = data[9:8];
	assign rd = data[7:6];
	assign func = data[5:0];
	assign imm = data[7:0];
	assign target_address = data[11:0];


	reg [`WORD_SIZE - 1:0] extended_imm;
	reg [`WORD_SIZE - 1:0] extended_target;

	reg [`WORD_SIZE - 1:0] registers[3:0];
	reg write_data;

	integer i;
	initial begin
		address = 16'h0000;
		pc = 16'h0000;
		for (i = 0; i< 4; i = i + 1) begin
			registers[i] = 16'h0000;
		end
		write_data = 0;
	end

	assign data = write_data ? registers[rt] : `WORD_SIZE'bz;

	/*
	wire [2:0] ALUOp;
	wire Regst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
	control_unit control_unit1(opcode, func, RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);
	*/

	reg [2:0] ALUOp;
	reg [`WORD_SIZE - 1:0] data_1, data_2;
	wire [`WORD_SIZE - 1:0] ALU_result;
	alu ALU(ALUOp, data_1, data_2, ALU_result);

	integer state; //state Identifier

	always @(inputReady) begin
	if(inputReady == 1 && state == 0)
		state = 1; //instruction fetch
	if(inputReady == 0 && state == 1)
		state = 2; //instruction execute
	if(inputReady == 1 && state == 2)
		state = 4; //read memory
	if(inputReady == 0 && state == 4)
		state = 3; //empty state(final state)
	end

	always @(ackOutput) 
	begin
		if(ackOutput == 1)
			state = 5; //write memory
		if(ackOutput == 0)
			state = 3; //empty state(final state)
	end

	reg [`WORD_SIZE - 1:0] extended_temp;

	always @(state) 
	begin
		if(state == 1) 
		begin // I stage
			readM = 0;
			pc = pc + 1;

        		extended_imm = 16'h0000;
        		extended_target = 16'h0000;

			extended_temp = 16'h0000;
	    	end

		if(state == 2) 
		begin
			extended_imm = (extended_imm | imm) << 8;
			for(i = 0; i < 8; i = i + 1) begin
				if(extended_imm[15] == 1)
					extended_imm = (extended_imm >> 1) + 16'h8000;
            			else
                			extended_imm = extended_imm >> 1;
			end

			extended_target = (extended_target | target_address) << 8;
			for(i = 0; i < 8; i = i + 1) begin
				if(extended_target[15] == 1)
			    	extended_target = (extended_target >> 1) + 16'h8000;
            			else
                			extended_target = extended_target >> 1;
			end

			if(opcode == `ALU_OP) 
			begin // R-type
				data_1 = registers[rs];
				data_2 = registers[rt];

				case(func)
				`INST_FUNC_ADD : 
					begin
						ALUOp = `FUNC_ADD;
						$display("%h + %h = %h", data_1, data_2, ALU_result);
						registers[rd] = data_1 + data_2; //ALU_result;
					end

				`INST_FUNC_SUB : 
					begin
						ALUOp = `FUNC_SUB;
						$display("%h - %h = %h", data_1, data_2, ALU_result);
						registers[rd] = ALU_result;
					end

				`INST_FUNC_AND : 
					begin
						ALUOp = `FUNC_AND;
						$display("%h & %h = %h", data_1, data_2, ALU_result);
						registers[rd] = ALU_result;
					end

				`INST_FUNC_ORR : 
					begin
						ALUOp = `FUNC_ORR;
						$display("%h | %h = %h", data_1, data_2, ALU_result);
						registers[rd] = ALU_result;
					end

				`INST_FUNC_NOT : 
					begin
						ALUOp = `FUNC_NOT;
						$display("%h * - 1 = %h", data_1, ALU_result);
						registers[rd] = ALU_result;
					end
				
				`INST_FUNC_TCP : 
					begin
                        $display("~%h + 1 = %h", data_1, ALU_result);
						ALUOp = `FUNC_TCP;
						registers[rd] = ALU_result;
					end

				`INST_FUNC_SHL : 
					begin
						ALUOp = `FUNC_SHL;
						registers[rd] = ALU_result;
					end

				`INST_FUNC_SHR : 
					begin
						ALUOp = `FUNC_SHR;
						registers[rd] = ALU_result;
						if(data_1[15] == 1)
							registers[rd] = registers[rd] + 16'h8000;
					end

				`INST_FUNC_JPR : 
					begin
						pc = data_1;
					end

				`INST_FUNC_JRL : 
					begin
						registers[2] = pc;
						pc = data_1;
					end
				endcase
			end

        		else 
			begin
				case(opcode) // I, J-type
				`ADI_OP	: 
					begin
						$display("ADI operation");
						registers[rt] = (registers[rs] + extended_imm);
					end

				`ORI_OP	: 
					begin
						$display("ORI operation");
						extended_temp = (extended_temp | imm);
						registers[rt] = registers[rs] | extended_temp;
					end

				`LHI_OP	: 
					begin
						$display("LHI operation");
						extended_temp = (extended_temp | imm);
						registers[rt] = (extended_temp << 8);
					end
	
				`LWD_OP	:
					begin
						$display("LWD operation");
						address = (registers[rs] + extended_imm);
						readM = 1;
					end
	
				`SWD_OP	:
					begin
						$display("SWD operation");
						address = (registers[rs] + extended_imm);
						write_data = 1;
						writeM = 1;
					end
	
				`BNE_OP	:
					begin
						$display("BNE operation");
						if(registers[rs] != registers[rt]) begin
							pc = (pc + extended_imm);
						end
					end
	
				`BEQ_OP	:
					begin
						$display("BEQ operation");
						if(registers[rs] == registers[rt]) begin
							pc = (pc + extended_imm);
						end
					end
	
				`BGZ_OP	:
					begin
						$display("BGZ operation");
						if((registers[rs][`WORD_SIZE - 1] == 0) && (registers[rs] != 0)) begin
							pc = (pc + extended_imm);
				 		end
					end
	
				`BLZ_OP	:
					begin
						$display("BLZ operation");
						if((registers[rs][`WORD_SIZE - 1] == 1) && (registers[rs] != 0)) begin
							pc = (pc + extended_imm);
				    		end
					end
	
				`JMP_OP	: 
					begin
						pc = (pc & 16'hf000);
						pc = (pc | extended_target);
					end
	
				`JAL_OP :
					begin
						registers[2] = pc;
						pc = (pc & 16'hf000);
						pc = (pc | extended_imm);
					end
				endcase	
			end

			state = 3;
		end

		if(state == 4) 
		begin
			readM = 0;
			registers[rt] = data;
		end

		if(state == 5) 
		begin
			writeM = 0;
			write_data = 0;
		end
	end

	always @(posedge clk) begin
		state = 0;
		address = pc;
		readM = 1;
	end
endmodule
