`include "opcodes.v"

module cpu (readM, writeM, address, data, ackOutput, inputReady, reset_n, clk);
    output reg readM;
    output writeM;
    output reg [`WORD_SIZE-1:0] address;
    inout wire [`WORD_SIZE-1:0] data;
    input ackOutput;
    input inputReady;
    input reset_n;                                 
    input clk;                                      
                                                                                                                                                      
    reg [`WORD_SIZE - 1:0] PC;
    wire [`WORD_SIZE - 1:0] nextPC;
    

    

    control_unit control_unit1 (ins, signal);

    //inputs for datapath
    wire DI_readM;
    wire DI_writeM; assign writeM = DI_writeM;
    wire [`WORD_SIZE-1:0] DI_address;
    reg [`WORD_SIZE-1:0] inputData;
    wire [`WORD_SIZE-1:0] outputData;

    reg first;

    data_path DP (
        DI_readM, 
        DI_writeM, 
        DI_address, 
        inputData, 
        outputData,
        ackOutput, 
        inputReady, 
        instruction, 
        signal, 
        clk,
        PC,
        nextPC, 
        reset_n
    );

    assign data = (!clk) ? outputData : `WORD_SIZE'bz;


    initial
    begin
        PC = 0;
        address = 0;
        readM = 1;
        first = 1;
    end

    always @(*) begin
        if(!reset_n) address = 0;
        else if(clk) address = PC;
        else address = DI_address;
    end

    always @ (posedge clk)
    begin
        if(!reset_n)
        begin
            first <= 1;
            PC <= -1;
            readM <= 1; 
        end
        else
        begin
            PC <= nextPC;
            readM <= 1;
        end
    end

    always @ (DI_readM)
    begin
        if(clk == 0) readM <= 1;
    end

    always @ (posedge inputReady)
    begin
        if(first)
        begin
            instruction = data;
            first = 0;
        end
        else begin
            if(clk > 0) instruction <= data;
            else if(clk == 0) inputData <= data;
            readM <= 0;
        end 
    end
    
endmodule