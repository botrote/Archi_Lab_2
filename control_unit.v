/*
    Main Control
*/

module control_unit (
    opcode,
    func
);
    input [3:0] opcode;
    input [5:0] func;

    output RegDst
    output Jump
    output Branch
    output MemRead
    output MemtoReg
    output [2:0] ALUOp // 8 ALU Function Codes
    output MemWrite
    output ALUSrc
    output Regwrite

    always @(*) begin

        RegDst = 0;
        Jump = 0;
        Branch = 0;
        MemRead = 0;
        MemtoReg = 0;
        ALUOp = 3'b000;
        MemWrite = 0;
        ALUSrc = 0;
        RegWrite = 0;

        case (opcode)
        ALU_OP : begin // R-format
            RegDst = 1;
            RegRead = 1;

            case (func)
            INST_FUNC_ADD : begin // ADD
                ALUOp = FUNC_ADD;
                RegWrite = 1;
            end
            INST_FUNC_SUB : begin // SUB
                ALUOp = FUNC_SUB;
                RegWrite = 1;
            end
            INST_FUNC_AND : begin // AND
                ALUOp = FUNC_AND;
                RegWrite = 1;
            end
            INST_FUNC_ORR : begin // ORR
                ALUOp = FUNC_ORR;
                RegWrite = 1;
            end
            INST_FUNC_NOT : begin // NOT
                ALUOp = FUNC_NOT;
                RegWrite = 1;
            end
            INST_FUNC_TCP : begin // TCP (Two's Complement)
                ALUOp = FUNC_TCP;
                RegWrite = 1;
            end
            INST_FUNC_SHL : begin // SHL (Shift Left)
                ALUOp = FUNC_SHL;
                RegWrite = 1;
            end
            INST_FUNC_SHR : begin // SHR (Shift Right)
                ALUOp = FUNC_SHR;
                RegWrite = 1;
            end
            6'b011011 : begin // RWD ---> not fin
            end
            6'b011100 : begin // WWD ---> not fin
            end
            INST_FUNC_JPR : begin // JPR ---> not fin
            end
            INST_FUNC_JRL : begin // JRL ---> not fin
            end
            endcase
        end

        ADI_OP : begin // I-type ADI (ADD Imm)
            ALUOp = 4'b0001;
            RegWrite = 1;
        end
        ORI_OP : begin // I-type ORI (OR Imm)
            ALUOp = 4'b0100;
            RegWrite = 1;
        end
        LHI_OP : begin // I-type LHI (Shift Left Imm)
            RegWrite = 1;
        end
        LWD_OP : begin // I-type LWD (Load)
            ALUOp = FUNC_ADD;
            MemtoReg = 1;
            RegWrite = 1;
        end
        SWD_OP : begin // I-type SWD (Store)
            ALUOp = FUNC_ADD;
            MemWrite = 1;
        end

        BNE_OP : begin // I-type BNE
            ALUOp = FUNC_SUB;
            Branch = 1;
        end
        BEQ_OP : begin // I-type BEQ
            ALUOp = FUNC_SUB;
            Branch = 1;
        end
        BGZ_OP : begin // I-type BGZ
            ALUOp = FUNC_SUB;
            Branch = 1;
        end
        BLZ_OP : begin // I-type BLZ
            ALUOp = FUNC_SUB;
            Branch = 1;
        end

        JMP_OP : begin // J-type JMP (Jump)
            Jump = 1;
        end
        JAL_OP : begin // J-type JAL
            Jump = 1;
        end
        endcase
    end    
endmodule
