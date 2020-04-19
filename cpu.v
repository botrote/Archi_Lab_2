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
	reg [3:0] opcode;
	reg [1:0] rs;
	reg [1:0] rt;
	reg [1:0] rd;
	reg [5:0] func;
	reg [7:0] imm;
	reg [11:0] target_address;

	wire [7:0] imm_wire, 
	wire [11:0] target_address_wire

	assign imm_wire = imm;
	assign target_address_wire = target_address;

	wire [`WORD_SIZE - 1:0] extended_target, extended_imm1, extended_imm2; 
	immediate_generator immGen(imm_wire, target_address_wire, extended_target, extended_imm1, extended_imm2);

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

	//reg [2:0] ALUOp;
	reg [`WORD_SIZE - 1:0] data_1, data_2;
	wire [`WORD_SIZE - 1:0] data_1_wire, data_2_wire;
	assign data_1_wire = data_1;
	assign data_2_wire = data_2;

	wire [`WORD_SIZE - 1:0] ALU_result;
	alu ALU(func, data_1_wire, data_2_wire, ALU_result);

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

			opcode = data[15:12];
			rs = data[11:10];
			rt = data[9:8];
			rd = data[7:6];
			func = data[5:0];
			imm = data[7:0];
			target_address = data[11:0];

			data_1 = registers[rs];
			data_2 = registers[rt];
	    	end

		if(state == 2) 
		begin
			if(opcode == `ALU_OP) 
			begin // R-type
				data_1 = registers[rs];
				data_2 = registers[rt];

				//$display("data1 %h data2 %h register1 %h register2 %h", data_1, data_2, registers[rs], registers[rt]);

				case(func)
				`INST_FUNC_ADD : 
					begin
						//$display("%h + %h = %h", data_1, data_2, ALU_result);
						registers[rd] = ALU_result;
					end

				`INST_FUNC_SUB : 
					begin
						//$display("%h - %h = %h", data_1, data_2, ALU_result);
						registers[rd] = ALU_result;
					end

				`INST_FUNC_AND : 
					begin
						//$display("%h & %h = %h", data_1, data_2, ALU_result);
						registers[rd] = ALU_result;
					end

				`INST_FUNC_ORR : 
					begin
						//$display("%h | %h = %h", data_1, data_2, ALU_result);
						registers[rd] = ALU_result;
					end

				`INST_FUNC_NOT : 
					begin
						//$display("%h * - 1 = %h", data_1, ALU_result);
						registers[rd] = ALU_result;
					end
				
				`INST_FUNC_TCP : 
					begin
                        //$display("~%h + 1 = %h", data_1, ALU_result);
						registers[rd] = ALU_result;
					end

				`INST_FUNC_SHL : 
					begin
						registers[rd] = ALU_result;
					end

				`INST_FUNC_SHR : 
					begin
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
						//$display("ADI operation");
						registers[rt] = (registers[rs] + extended_imm1);
					end

				`ORI_OP	: 
					begin
						//$display("ORI operation");
						registers[rt] = registers[rs] | extended_imm2;
					end

				`LHI_OP	: 
					begin
						//$display("LHI operation");
						registers[rt] = extended_imm2;
					end
	
				`LWD_OP	:
					begin
						$display("LWD operation");
						address = (registers[rs] + extended_imm1);
						readM = 1;
					end
	
				`SWD_OP	:
					begin
						$display("SWD operation");
						address = (registers[rs] + extended_imm1);
						write_data = 1;
						writeM = 1;
					end
	
				`BNE_OP	:
					begin
						$display("BNE operation");
						if(registers[rs] != registers[rt]) begin
							pc = (pc + extended_imm1);
						end
					end
	
				`BEQ_OP	:
					begin
						$display("BEQ operation");
						if(registers[rs] == registers[rt]) begin
							pc = (pc + extended_imm1);
						end
					end
	
				`BGZ_OP	:
					begin
						$display("BGZ operation");
						if((registers[rs][`WORD_SIZE - 1] == 0) && (registers[rs] != 0)) begin
							pc = (pc + extended_imm1);
				 		end
					end
	
				`BLZ_OP	:
					begin
						$display("BLZ operation");
						if((registers[rs][`WORD_SIZE - 1] == 1) && (registers[rs] != 0)) begin
							pc = (pc + extended_imm1);
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
						pc = (pc | extended_imm1);
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
