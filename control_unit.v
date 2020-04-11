module control_unit (
    opcode,
    func
);
    input [4:0] opcode;
    input [6:0] func;

    output RegDst
    output Jump
    output Branch
    output MemRead
    output MemtoReg
    output [4:0] ALUOp // ???
    output MemWrite
    output ALUSrc
    output Regwrite

    always @(*) begin

        RegDst = 0;
        Jump = 0;
        Branch = 0;
        MemRead = 0;
        MemtoReg = 0;
        ALUOp = 4'b0000;
        MemWrite = 0;
        ALUSrc = 0;
        RegWrite = 0;

        case (opcode)
        4'b1111 : begin // R-format
            RegDst = 1;
            RegRead = 1;

            case (func)
            6'b000000 : begin // ADD
                ALUOp = 4'b0001;
                RegWrite = 1;
            end
            6'b000001 : begin // SUB
                ALUOp = 4'b0010;
                RegWrite = 1;
            end
            6'b000010 : begin // AND
                ALUOp = 4'b0011;
                RegWrite = 1;
            end
            6'b000011 : begin // ORR
                ALUOp = 4'b0100;
                RegWrite = 1;
            end
            6'b000100 : begin // NOT
                ALUOp = 4'b0101;
                RegWrite = 1;
            end
            6'b000101 : begin // TCP (Two's Complement)
                ALUOp = 4'b0110;
                RegWrite = 1;
            end
            6'b000110 : begin // SHL (Shift Left)
                ALUOp = 4'b0111;
                RegWrite = 1;
            end
            6'b000111 : begin // SHR (Shift Right)
                ALUOp = 4'b1000;
                RegWrite = 1;
            end
            6'b011011 : begin // RWD ---> not fin
            end
            6'b011100 : begin // WWD ---> not fin
            end
            6'b011001 : begin // JPR ---> not fin
            end
            6'b011010 : begin // JRL ---> not fin
            end
            6'b011101 : begin // HLT ---> not fin
            end
            6'b011110 : begin // ENI ---> not fin
            end
            6'b011111 : begin // DSI ---> not fin
            end
            endcase
        end

        6'b000100 : begin // I-type ADI (ADD Imm)
            ALUOp = 4'b0001;
            RegWrite = 1;
        end
        6'b000101 : begin // I-type ORI (OR Imm)
            ALUOp = 4'b0100;
            RegWrite = 1;
        end
        6'b000110 : begin // I-type LHI (Shift Left Imm)
        end
        6'b000111 : begin // I-type LWD (Load)
        end
        6'b001000 : begin // I-type SWD (Store)
        end

        6'b000000 : begin // I-type BNE
            Branch = 1;
        end
        6'b000001 : begin // I-type BEQ
            Branch = 1;
        end
        6'b000010 : begin // I-type BGZ
            Branch = 1;
        end
        6'b000011 : begin // I-type BLZ
            Branch = 1;
        end

        6'b001001 : begin // J-type JMP (Jump)
            Jump = 1;
        end
        6'b001010 : begin // J-type JAL
            Jump = 1;
        end
        endcase
    end    
endmodule
