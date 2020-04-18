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

	reg readM;
	reg writeM;
	reg [`WORD_SIZE -1:0] address;
	reg [3:0]opcode;
	reg [1:0]rs;
	reg [1:0]rt;
	reg [1:0]rd;
	reg [5:0]func;
	reg [7:0]imm;
	reg [11:0]jumpimm;
	reg [`WORD_SIZE -1 :0]se;
	reg [`WORD_SIZE - 1:0]regi[3:0];
	reg [`WORD_SIZE - 1:0]pc;
	reg write_data;
	integer i;

	function [`WORD_SIZE-1:0]ARS;
		input [`WORD_SIZE-1:0]A;
		begin
			if(A[`WORD_SIZE-1]==1)
				ARS=((A>>1)+16'h8000);
			else
				ARS=(A>>1);
		end
	endfunction

	initial begin
		pc = 16'h000;
		for (i = 0; i< 4; i = i + 1)begin
			regi[i] = 16'h0000;
		end
		address = 16'h0000;
		write_data = 0;
	end

	assign data = write_data ? regi[rt] : `WORD_SIZE'bz;

	always @(posedge clk) begin
		address = pc;
		readM = 1;
		wait(inputReady);
		readM = 0;
		opcode = data[`WORD_SIZE - 1: 12];
		rs = data[11: 10];
		rt = data[9: 8];
		rd = data[7: 6];
		func = data[5:0];
		imm = data[7:0];
		jumpimm = data[11:0];
		se = 16'h0000;
		pc = pc + 1;
		wait(!inputReady);
		case(opcode)
			`ADI_OP	:begin
				se = (se | imm);
				se = (se << 8);
				for(i = 0; i< 8; i = i + 1) begin
					se = ARS(se);
				end
				regi[rt] = (regi[rs] + se);
				end//4'd4
			`ORI_OP	:begin
				se = (se | imm);
				regi[rt] = (regi[rs] | se);
				end	//4'd5
			`LHI_OP	:begin
				se = (se | imm);
				se = (se << 8);
				regi[rt] = se;
				end	//4'd6
			`LWD_OP	:begin
				se = (se | imm);
				se = (se << 8);
				for(i = 0; i< 8; i = i + 1) begin
					se = ARS(se);
				end
				address = (regi[rs] + se);
				readM = 1;
				wait(inputReady);
				readM = 0;
				regi[rt] = data;
				wait(!inputReady);
			end	//4'd7
			`SWD_OP	:begin
				se = (se | imm);
				se = (se << 8);
				for(i = 0; i< 8; i = i + 1) begin
					se = ARS(se);
				end
				address = (regi[rs] + se);
				write_data = 1;
				writeM = 1;
				wait(ackOutput);
				writeM = 0;
				write_data = 0;
				wait(!ackOutput);
				end	//4'd8
			`BNE_OP	:begin
				se = (se | imm);
				se = (se << 8);
				for(i = 0; i< 8; i = i + 1) begin
					se = ARS(se);
				end
				if(regi[rs] != regi[rt])begin
					pc = (pc + se);
				end
			end	//4'd0
			`BEQ_OP	:begin
				se = (se | imm);
				se = (se << 8);
				for(i = 0; i< 8; i = i + 1) begin
					se = ARS(se);
				end
				if(regi[rs] == regi[rt])begin
					pc = (pc + se);
				end
			end	//4'd1
			`BGZ_OP	:begin
				se = (se | imm);
				se = (se << 8);
				for(i = 0; i< 8; i = i + 1) begin
					se = ARS(se);
				end
				if( (regi[rs][`WORD_SIZE - 1] == 0) && (regi[rs] != 0) )begin
					pc = (pc + se);
				end
			end	//4'd2
			`BLZ_OP	:begin
				se = (se | imm);
				se = (se << 8);
				for(i = 0; i< 8; i = i + 1) begin
					se = ARS(se);
				end
				if( (regi[rs][`WORD_SIZE - 1] == 1) && (regi[rs] != 0) )begin
					pc = (pc + se);
				end
			end	//4'd3
			`JMP_OP	:begin
				se = (se | jumpimm);
				se = (se << 8);
				for(i = 0; i< 8; i = i + 1) begin
					se = ARS(se);
				end
				pc = (pc & 16'hf000);
				pc = (pc | se);
			end	//4'd9
			`JAL_OP :begin
				regi[2] = pc;
				se = (se | imm);
				se = (se << 8);
				for(i = 0; i< 8; i = i + 1) begin
					se = ARS(se);
				end
				pc = (pc & 16'hf000);
				pc = (pc | se);
			end	//4'd10
			default :begin
				case(func)
					`FUNC_ADD : begin
						regi[rd] = (regi[rs] + regi[rt]);
					end	//3'b000
					`FUNC_SUB : begin
						regi[rd] = (regi[rs] - regi[rt]);
					end //3'b001
					`FUNC_AND : begin
						regi[rd] = (regi[rs] & regi[rt]);
					end	//3'b010
					`FUNC_ORR :	begin
						regi[rd] = (regi[rs] | regi[rt]);
					end//3'b011
					`FUNC_NOT :	begin
						regi[rd] = ~regi[rs];
					end	//3'b100
					`FUNC_TCP :	begin
						regi[rd] = (~regi[rs] + 1);
					end	//3'b101
					`FUNC_SHL : begin
						regi[rd] = (regi[rs] << 1);
					end		//3'b110
					`FUNC_SHR : begin
						regi[rd] = ARS(regi[rs]);
					end	//3'b111
					//`INST_FUNC_ADD : 	//6'd0
					//`INST_FUNC_SUB :	//6'd1
					//`INST_FUNC_AND :	//6'd2
					//`INST_FUNC_ORR :	//6'd3
					//`INST_FUNC_NOT :	//6'd4
					//`INST_FUNC_TCP :	//6'd5
					//`INST_FUNC_SHL :	//6'd6
					//`INST_FUNC_SHR :	//6'd7
					`INST_FUNC_JPR : begin
						pc = regi[rs];
					end	//6'd25
					`INST_FUNC_JRL : begin
						regi[2] = pc;
						pc = regi[rs];
					end	//6'd26
				endcase
			end	//4'd15 ALU, JPR, JRL
		endcase
	end
endmodule
